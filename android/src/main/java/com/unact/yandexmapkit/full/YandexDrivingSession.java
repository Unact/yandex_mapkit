package com.unact.yandexmapkit.full;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.directions.driving.DrivingRoute;
import com.yandex.mapkit.directions.driving.DrivingRouter;
import com.yandex.mapkit.directions.driving.DrivingSession;
import com.yandex.mapkit.directions.driving.VehicleOptions;
import com.yandex.mapkit.directions.driving.Weight;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexDrivingSession implements MethodChannel.MethodCallHandler {
  private final int id;
  private DrivingSession session;
  private final MethodChannel methodChannel;
  private final DrivingRouter drivingRouter;
  @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
  private static final Map<Integer, YandexDrivingSession> drivingSessions = new HashMap<>();

  public static void initSession(int id, BinaryMessenger messenger, DrivingRouter drivingRouter) {
    drivingSessions.put(id, new YandexDrivingSession(id, messenger, drivingRouter));
  }

  public YandexDrivingSession(
    int id,
    BinaryMessenger messenger,
    DrivingRouter drivingRouter
  ) {
    this.id = id;
    this.drivingRouter = drivingRouter;

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_driving_session_" + id);
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "requestRoutes":
        requestRoutes(call, result);
        break;
      case "cancel":
        cancel();
        result.success(null);
        break;
      case "retry":
        retry(result);
        break;
      case "close":
        close();
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void requestRoutes(final MethodCall call, final Result result) {
    YandexDrivingSession self = this;
    Map<String, Object> params = (Map<String, Object>) call.arguments;
    List<RequestPoint> points = new ArrayList<>();
    for (Map<String, Object> pointParams : (List<Map<String, Object>>) params.get("points")) {
      points.add(UtilsFull.requestPointFromJson(pointParams));
    }

    session = drivingRouter.requestRoutes(
      points,
      UtilsFull.drivingOptionsFromJson((Map<String, Object>) params.get("drivingOptions")),
      new VehicleOptions(),
      new DrivingSession.DrivingRouteListener() {
        @Override
        public void onDrivingRoutes(@NonNull List<DrivingRoute> list) { self.onDrivingRoutes(list, result); }
        @Override
        public void onDrivingRoutesError(@NonNull Error error) { self.onDrivingRoutesError(error, result); }
      }
    );
  }

  public void cancel() {
    session.cancel();
  }

  public void retry(MethodChannel.Result result) {
    YandexDrivingSession self = this;

    session.retry(
      new DrivingSession.DrivingRouteListener() {
        @Override
        public void onDrivingRoutes(@NonNull List<DrivingRoute> list) { self.onDrivingRoutes(list, result); }
        @Override
        public void onDrivingRoutesError(@NonNull Error error) { self.onDrivingRoutesError(error, result); }
      }
    );
  }

  public void close() {
    session.cancel();
    methodChannel.setMethodCallHandler(null);

    drivingSessions.remove(id);
  }

  private void onDrivingRoutes(@NonNull List<DrivingRoute> list, @NonNull Result result) {
    List<Map<String, Object>> resultRoutes = new ArrayList<>();
    for (DrivingRoute route : list) {
      Weight weight = route.getMetadata().getWeight();
      Map<String, Object> resultWeight = new HashMap<>();
      resultWeight.put("time", UtilsFull.localizedValueToJson(weight.getTime()));
      resultWeight.put("timeWithTraffic", UtilsFull.localizedValueToJson(weight.getTimeWithTraffic()));
      resultWeight.put("distance", UtilsFull.localizedValueToJson(weight.getDistance()));
      Map<String, Object> resultMetadata = new HashMap<>();
      resultMetadata.put("weight", resultWeight);

      Map<String, Object> resultRoute = new HashMap<>();
      resultRoute.put("geometry", UtilsFull.polylineToJson(route.getGeometry()));
      resultRoute.put("metadata", resultMetadata);

      resultRoutes.add(resultRoute);
    }

    Map<String, Object> resultMap = new HashMap<>();
    resultMap.put("routes", resultRoutes);

    result.success(resultMap);
  }

  private void onDrivingRoutesError(@NonNull Error error, @NonNull Result result) {
    result.success(UtilsFull.errorToJson(error));
  }
}
