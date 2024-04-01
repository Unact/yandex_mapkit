package com.unact.yandexmapkit.full;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.transport.bicycle.BicycleRouter;
import com.yandex.mapkit.transport.bicycle.Route;
import com.yandex.mapkit.transport.bicycle.Session;
import com.yandex.mapkit.transport.bicycle.VehicleType;
import com.yandex.mapkit.transport.bicycle.Weight;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexBicycleSession implements MethodChannel.MethodCallHandler {
  private final int id;
  private Session session;
  private final MethodChannel methodChannel;
  private final BicycleRouter bicycleRouter;
  @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
  private static final Map<Integer, YandexBicycleSession> bicycleSessions = new HashMap<>();

  public static void initSession(int id, BinaryMessenger messenger, BicycleRouter bicycleRouter) {
    bicycleSessions.put(id, new YandexBicycleSession(id, messenger, bicycleRouter));
  }

  public YandexBicycleSession(
    int id,
    BinaryMessenger messenger,
    BicycleRouter bicycleRouter
  ) {
    this.id = id;
    this.bicycleRouter = bicycleRouter;

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_bicycle_session_" + id);
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
    YandexBicycleSession self = this;
    Map<String, Object> params = (Map<String, Object>) call.arguments;
    List<RequestPoint> points = new ArrayList<>();
    for (Map<String, Object> pointParams : (List<Map<String, Object>>) params.get("points")) {
      points.add(UtilsFull.requestPointFromJson(pointParams));
    }

    session = bicycleRouter.requestRoutes(
      points,
      VehicleType.values()[(Integer) params.get("bicycleVehicleType")],
      new Session.RouteListener() {
        @Override
        public void onBicycleRoutes(@NonNull List<Route> list) { self.onBicycleRoutes(list, result); }
        @Override
        public void onBicycleRoutesError(@NonNull Error error) { self.onBicycleRoutesError(error, result);}
      }
    );
  }

  public void cancel() {
    session.cancel();
  }

  public void retry(MethodChannel.Result result) {
    YandexBicycleSession self = this;

    session.retry(
      new Session.RouteListener() {
        @Override
        public void onBicycleRoutes(@NonNull List<Route> list) { self.onBicycleRoutes(list, result); }
        @Override
        public void onBicycleRoutesError(@NonNull Error error) { self.onBicycleRoutesError(error, result);}
      }
    );
  }

  public void close() {
    session.cancel();
    methodChannel.setMethodCallHandler(null);

    bicycleSessions.remove(id);
  }

  private void onBicycleRoutes(@NonNull List<Route> list, @NonNull Result result) {
    List<Map<String, Object>> resultRoutes = new ArrayList<>();
    for (Route route : list) {
      Weight weight = route.getWeight();
      Map<String, Object> resultWeight = new HashMap<>();
      resultWeight.put("time", UtilsFull.localizedValueToJson(weight.getTime()));
      resultWeight.put("distance", UtilsFull.localizedValueToJson(weight.getDistance()));

      Map<String, Object> resultRoute = new HashMap<>();
      resultRoute.put("geometry", UtilsFull.polylineToJson(route.getGeometry()));
      resultRoute.put("weight", resultWeight);

      resultRoutes.add(resultRoute);
    }

    Map<String, Object> resultMap = new HashMap<>();
    resultMap.put("routes", resultRoutes);

    result.success(resultMap);
  }

  private void onBicycleRoutesError(@NonNull Error error, @NonNull Result result) {
    result.success(UtilsFull.errorToJson(error));
  }
}
