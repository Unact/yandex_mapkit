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
import com.yandex.mapkit.directions.driving.DrivingSession;
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

public class YandexDrivingRouterHandlerImpl implements MethodCallHandler {
    private final DrivingRouter drivingRouter;

    private final Map<Integer, DrivingSession> sessions = new HashMap<>();

    public YandexDrivingRouterHandlerImpl(Context context) {
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
            case "cancelDrivingSession":
                cancelDrivingSession(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @SuppressWarnings("unchecked")
    private void requestRoutes(final MethodCall call, final Result result) {
        final Map<String, Object> params = (Map<String, Object>) call.arguments;
        final List<Map<String, Object>> pointsParams = (List<Map<String, Object>>) params.get("points");
        final Integer sessionId = (Integer) params.get("sessionId");
        final List<RequestPoint> points = requestPoints(pointsParams);

        final DrivingSession session = drivingRouter.requestRoutes(
                points,
                new DrivingOptions(),
                new VehicleOptions(),
                new DrivingRouteListenerImpl(sessionId, result)
        );
        sessions.put(sessionId, session);
    }

    @SuppressWarnings("unchecked")
    private RequestPoint requestPoint(Map<String, Object> data) {
        final Map<String, Object> paramsPoint = (Map<String, Object>) data.get("point");
        Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));

        final String pointTypeParams = (String) data.get("requestPointType");
        final RequestPointType pointType = RequestPointType.valueOf(pointTypeParams.toUpperCase());

        return new RequestPoint(point, pointType, null);
    }

    private List<RequestPoint> requestPoints(List<Map<String, Object>> pointsParams) {
        final List<RequestPoint> points = new ArrayList<>();
        for (final Map<String, Object> pointParams : pointsParams) {
            points.add(requestPoint(pointParams));
        }
        return points;
    }

    @SuppressWarnings("unchecked")
    private void cancelDrivingSession(final MethodCall call, final Result result) {
        final Map<String, Object> params = (Map<String, Object>) call.arguments;
        final Integer sessionId = (Integer) params.get("sessionId");
        final DrivingSession session = sessions.get(sessionId);
        if (session != null) {
            session.cancel();
            sessions.remove(sessionId);
        }
        result.success(null);
    }

    private class DrivingRouteListenerImpl implements DrivingRouteListener {
        private final Integer sessionId;
        private final Result result;

        public DrivingRouteListenerImpl(Integer sessionId, Result result) {
            this.sessionId = sessionId;
            this.result = result;
        }

        @Override
        public void onDrivingRoutes(@NonNull List<DrivingRoute> list) {
            sessions.remove(sessionId);
            Map<String, Object> resultMap = new HashMap<>();
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
            resultMap.put("routes", resultRoutes);
            result.success(resultMap);
        }

        @Override
        public void onDrivingRoutesError(@NonNull Error error) {
            sessions.remove(sessionId);
            Map<String, Object> resultMap = new HashMap<>();
            resultMap.put("error", error.getClass().getName());
            result.success(resultMap);
        }
    }
}
