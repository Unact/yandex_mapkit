package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.RequestPointType;
import com.yandex.mapkit.directions.Directions;
import com.yandex.mapkit.directions.DirectionsFactory;
import com.yandex.mapkit.directions.driving.DrivingOptions;
import com.yandex.mapkit.directions.driving.DrivingRoute;
import com.yandex.mapkit.directions.driving.DrivingRouter;
import com.yandex.mapkit.directions.driving.DrivingSession.DrivingRouteListener;
import com.yandex.mapkit.directions.driving.VehicleOptions;
import com.yandex.mapkit.geometry.Point;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexDrivingRouterImpl implements MethodCallHandler {
    private final DrivingRouter drivingRouter;

    public YandexDrivingRouterImpl(Context context) {
        DirectionsFactory.initialize(context);
        final Directions directions = DirectionsFactory.getInstance();
        drivingRouter = directions.createDrivingRouter();
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "requestRoutes":
                requestRoutes(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @SuppressWarnings("unchecked")
    private void requestRoutes(MethodCall call, final Result result) {
        final Map<String, Object> params = (Map<String, Object>) call.arguments;
        final List<Map<String, Object>> pointsParams = (List<Map<String, Object>>) params.get("points");
        final List<RequestPoint> points = new ArrayList<RequestPoint>();
        for (final Map<String, Object> pointParams : pointsParams) {
            points.add(requestPoint(pointParams));
        }
        drivingRouter.requestRoutes(
                points,
                new DrivingOptions(),
                new VehicleOptions(),
                new DrivingRouteListener() {

                    @Override
                    public void onDrivingRoutes(@NonNull List<DrivingRoute> list) {
                        List<Map<String, Object>> resultRoutes = new ArrayList<>();
                        for (DrivingRoute route : list) {
                            Map<String, Object> resultRoute = new HashMap<>();
                            List<Map<String, Object>> resultPoints = new ArrayList<>();
                            for (Point point : route.getGeometry().getPoints()) {
                                Map<String, Object> resultPoint = new HashMap<>();
                                resultPoint.put("latitude", point.getLatitude());
                                resultPoint.put("longitude", point.getLongitude());
                                resultPoints.add(resultPoint);
                            }
                            resultRoute.put("geometry", resultPoints);
                            resultRoutes.add(resultRoute);
                        }
                        result.success(resultRoutes);
                    }

                    @Override
                    public void onDrivingRoutesError(@NonNull Error error) {
                        result.error("onDrivingRoutesError", null, null);
                    }
                }


        );
    }

    @SuppressWarnings("unchecked")
    private RequestPoint requestPoint(Map<String, Object> data) {
        final Map<String, Object> paramsPoint = (Map<String, Object>) data.get("point");
        Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));

        final String pointTypeParams = (String) data.get("requestPointType");
        final RequestPointType pointType = RequestPointType.valueOf(pointTypeParams);

        return new RequestPoint(point, pointType, null);
    }
}
