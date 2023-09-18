package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.directions.driving.DrivingRoute;
import com.yandex.mapkit.directions.driving.DrivingSession;
import com.yandex.mapkit.directions.driving.Weight;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexDrivingListener implements DrivingSession.DrivingRouteListener {
    private final MethodChannel.Result result;

    public YandexDrivingListener(MethodChannel.Result result) {
        this.result = result;
    }

    @Override
    public void onDrivingRoutes(@NonNull List<DrivingRoute> list) {
        List<Map<String, Object>> resultRoutes = new ArrayList<>();
        for (DrivingRoute route : list) {
            Weight weight = route.getMetadata().getWeight();
            Map<String, Object> resultWeight = new HashMap<>();
            resultWeight.put("time", Utils.localizedValueToJson(weight.getTime()));
            resultWeight.put("timeWithTraffic", Utils.localizedValueToJson(weight.getTimeWithTraffic()));
            resultWeight.put("distance", Utils.localizedValueToJson(weight.getDistance()));
            Map<String, Object> resultMetadata = new HashMap<>();
            resultMetadata.put("weight", resultWeight);

            Map<String, Object> resultRoute = new HashMap<>();
            resultRoute.put("polyline", Utils.polylineToJson(route.getGeometry()));
            resultRoute.put("metadata", resultMetadata);

            resultRoutes.add(resultRoute);
        }

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("routes", resultRoutes);

        result.success(resultMap);
    }

    @Override
    public void onDrivingRoutesError(@NonNull Error error) {
        result.success(Utils.errorToJson(error));
    }
}
