package com.unact.yandexmapkit.full;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.transport.masstransit.PedestrianRouter;
import com.yandex.mapkit.transport.masstransit.Route;
import com.yandex.mapkit.transport.masstransit.RouteOptions;
import com.yandex.mapkit.transport.masstransit.Session;
import com.yandex.mapkit.transport.masstransit.TravelEstimation;
import com.yandex.mapkit.transport.masstransit.Weight;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexPedestrianSession implements MethodChannel.MethodCallHandler {
  private final int id;
  private Session session;
  private final MethodChannel methodChannel;
  private final PedestrianRouter pedestrianRouter;
  @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
  private static final Map<Integer, YandexPedestrianSession> pedestrianSessions = new HashMap<>();

  public static void initSession(int id, BinaryMessenger messenger, PedestrianRouter pedestrianRouter) {
    pedestrianSessions.put(id, new YandexPedestrianSession(id, messenger, pedestrianRouter));
  }

  public YandexPedestrianSession(
    int id,
    BinaryMessenger messenger,
    PedestrianRouter pedestrianRouter
  ) {
    this.id = id;
    this.pedestrianRouter = pedestrianRouter;

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_pedestrian_session_" + id);
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
    YandexPedestrianSession self = this;
    Map<String, Object> params = (Map<String, Object>) call.arguments;
    List<RequestPoint> points = new ArrayList<>();
    for (Map<String, Object> pointParams : (List<Map<String, Object>>) params.get("points")) {
      points.add(UtilsFull.requestPointFromJson(pointParams));
    }

    session = pedestrianRouter.requestRoutes(
      points,
      UtilsFull.timeOptionsFromJson((Map<String, Object>) params.get("timeOptions")),
      new RouteOptions(UtilsFull.fitnessOptionsFromJson((Map<String, Object>) params.get("fitnessOptions"))),
      new Session.RouteListener() {
        @Override
        public void onMasstransitRoutes(@NonNull List<Route> list) { self.onMasstransitRoutes(list, result); }
        @Override
        public void onMasstransitRoutesError(@NonNull Error error) { self.onMasstransitRoutesError(error, result); }
      }
    );
  }

  public void cancel() {
    session.cancel();
  }

  public void retry(MethodChannel.Result result) {
    YandexPedestrianSession self = this;

    session.retry(
      new Session.RouteListener() {
        @Override
        public void onMasstransitRoutes(@NonNull List<Route> list) { self.onMasstransitRoutes(list, result); }
        @Override
        public void onMasstransitRoutesError(@NonNull Error error) { self.onMasstransitRoutesError(error, result); }
      }
    );
  }

  public void close() {
    session.cancel();
    methodChannel.setMethodCallHandler(null);

    pedestrianSessions.remove(id);
  }

  private void onMasstransitRoutes(@NonNull List<Route> list, @NonNull Result result) {
    List<Map<String, Object>> resultRoutes = new ArrayList<>();
    for (Route route : list) {
      Weight weight = route.getMetadata().getWeight();
      TravelEstimation estimation = route.getMetadata().getEstimation();

      Map<String, Object> resultWeight = new HashMap<>();
      resultWeight.put("time", UtilsFull.localizedValueToJson(weight.getTime()));
      resultWeight.put("walkingDistance", UtilsFull.localizedValueToJson(weight.getWalkingDistance()));
      resultWeight.put("transfersCount", weight.getTransfersCount());

      Map<String, Object> resultEstimation = estimation != null ? new HashMap<>() : null;
      if (resultEstimation != null) {
        resultEstimation.put("departureTime", estimation.getDepartureTime().getValue() * 1000);
        resultEstimation.put("arrivalTime", estimation.getArrivalTime().getValue() * 1000);
      }

      Map<String, Object> resultMetadata = new HashMap<>();
      resultMetadata.put("weight", resultWeight);
      resultMetadata.put("estimation", resultEstimation);

      Map<String, Object> resultRoute = new HashMap<>();
      resultRoute.put("geometry", UtilsFull.polylineToJson(route.getGeometry()));
      resultRoute.put("metadata", resultMetadata);

      resultRoutes.add(resultRoute);
    }

    Map<String, Object> resultMap = new HashMap<>();
    resultMap.put("routes", resultRoutes);

    result.success(resultMap);
  }

  private void onMasstransitRoutesError(@NonNull Error error, @NonNull Result result) {
    result.success(UtilsFull.errorToJson(error));
  }
}
