package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.transport.bicycle.Route;
import com.yandex.mapkit.transport.bicycle.Session;
import com.yandex.mapkit.transport.bicycle.Weight;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexBicycleListener implements Session.RouteListener {
    private final MethodChannel.Result result;

    public YandexBicycleListener(MethodChannel.Result result) {
        this.result = result;
    }

    @Override
    public void onBicycleRoutes(@NonNull List<Route> list) {
        List<Map<String, Object>> resultRoutes = new ArrayList<>();
        for (Route route : list) {
            Weight weight = route.getWeight();
            Map<String, Object> resultWeight = new HashMap<>();
            resultWeight.put("time", Utils.localizedValueToJson(weight.getTime()));
            resultWeight.put("distance", Utils.localizedValueToJson(weight.getDistance()));

            Map<String, Object> resultRoute = new HashMap<>();
            resultRoute.put("polyline", Utils.polylineToJson(route.getGeometry()));
            resultRoute.put("weight", resultWeight);

            resultRoutes.add(resultRoute);
        }

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("routes", resultRoutes);

        result.success(resultMap);
    }

    @Override
    public void onBicycleRoutesError(@NonNull Error error) {
        result.success(Utils.errorToJson(error));
    }
}
