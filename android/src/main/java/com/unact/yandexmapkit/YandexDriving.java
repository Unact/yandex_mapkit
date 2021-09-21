package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.RequestPointType;
import com.yandex.mapkit.directions.DirectionsFactory;
import com.yandex.mapkit.directions.driving.DrivingOptions;
import com.yandex.mapkit.directions.driving.DrivingRouter;
import com.yandex.mapkit.directions.driving.DrivingSession;
import com.yandex.mapkit.directions.driving.VehicleOptions;
import com.yandex.mapkit.geometry.Point;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexDriving implements MethodCallHandler {
  private final DrivingRouter drivingRouter;
  private final BinaryMessenger binaryMessenger;
  private final Map<Integer, YandexDrivingSession> drivingSessions = new HashMap<>();

  public YandexDriving(Context context, BinaryMessenger messenger) {
    DirectionsFactory.initialize(context);

    drivingRouter = DirectionsFactory.getInstance().createDrivingRouter();
    binaryMessenger = messenger;
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
  private void requestRoutes(final MethodCall call, final Result result) {
    Map<String, Object> params = (Map<String, Object>) call.arguments;
    Integer sessionId = (Integer) params.get("sessionId");
    List<Map<String, Object>> pointsParams = (List<Map<String, Object>>) params.get("points");
    List<RequestPoint> points = requestPoints(pointsParams);

    DrivingSession session = drivingRouter.requestRoutes(
      points,
      new DrivingOptions(),
      new VehicleOptions(),
      new YandexDrivingListener(result)
    );

    YandexDrivingSession drivingSession = new YandexDrivingSession(
      sessionId,
      session,
      binaryMessenger,
      new DrivingCloseListener()
    );

    drivingSessions.put(sessionId, drivingSession);
  }

  @SuppressWarnings("unchecked")
  private RequestPoint requestPoint(Map<String, Object> data) {
    Map<String, Object> paramsPoint = (Map<String, Object>) data.get("point");
    Integer requestPointType = (Integer) data.get("requestPointType");

    Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));
    RequestPointType pointType = RequestPointType.values()[requestPointType];

    return new RequestPoint(point, pointType, null);
  }

  private List<RequestPoint> requestPoints(List<Map<String, Object>> pointsParams) {
    List<RequestPoint> points = new ArrayList<>();

    for (Map<String, Object> pointParams : pointsParams) {
      points.add(requestPoint(pointParams));
    }

    return points;
  }

  public class DrivingCloseListener {
    public void onClose(int id) {
      drivingSessions.remove(id);
    }
  }
}
