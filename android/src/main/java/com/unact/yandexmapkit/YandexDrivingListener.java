package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.LocalizedValue;
import com.yandex.mapkit.directions.driving.DrivingRoute;
import com.yandex.mapkit.directions.driving.DrivingSession;
import com.yandex.mapkit.directions.driving.Weight;
import com.yandex.mapkit.geometry.Point;
import com.yandex.runtime.Error;
import com.yandex.runtime.network.NetworkError;
import com.yandex.runtime.network.RemoteError;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexDrivingListener implements DrivingSession.DrivingRouteListener  {
  private final MethodChannel.Result result;

  public YandexDrivingListener(MethodChannel.Result result) {
    this.result = result;
  }

  @Override
  public void onDrivingRoutes(@NonNull List<DrivingRoute> list) {
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

      Weight weight = route.getMetadata().getWeight();
      Map<String, Object> resultWeight = new HashMap<>();
      resultWeight.put("time", localizedValueData(weight.getTime()));
      resultWeight.put("timeWithTraffic", localizedValueData(weight.getTimeWithTraffic()));
      resultWeight.put("distance", localizedValueData(weight.getDistance()));

      Map<String, Object> resultMetadata = new HashMap<>();
      resultMetadata.put("weight", resultWeight);
      resultRoute.put("metadata", resultMetadata);

      resultRoutes.add(resultRoute);
    }
    resultMap.put("routes", resultRoutes);
    result.success(resultMap);
  }

  @Override
  public void onDrivingRoutesError(@NonNull Error error) {
    String errorMessage = "Unknown error";

    if (error instanceof NetworkError) {
      errorMessage = "Network error";
    }

    if (error instanceof RemoteError) {
      errorMessage = "Remote server error";
    }

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("error", errorMessage);

    result.success(arguments);
  }

  private Map<String, Object> localizedValueData(LocalizedValue value) {
    Map<String, Object> result = new HashMap<>();
    result.put("value", value.getValue());
    result.put("text", value.getText());
    return result;
  }
}
