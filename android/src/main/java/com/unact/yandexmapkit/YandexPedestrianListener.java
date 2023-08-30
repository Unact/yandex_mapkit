package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.transport.masstransit.Route;
import com.yandex.mapkit.transport.masstransit.Session;
import com.yandex.mapkit.transport.masstransit.Weight;
import com.yandex.runtime.Error;
import com.yandex.runtime.network.NetworkError;
import com.yandex.runtime.network.RemoteError;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexPedestrianListener implements Session.RouteListener {
    private final MethodChannel.Result result;

    public YandexPedestrianListener(MethodChannel.Result result) {
        this.result = result;
    }

    @Override
    public void onMasstransitRoutes(@NonNull List<Route> list) {
        List<Map<String, Object>> resultRoutes = new ArrayList<>();
        for (Route route : list) {
            List<Map<String, Double>> resultPoints = new ArrayList<>();
            for (Point point : route.getGeometry().getPoints()) {
                resultPoints.add(Utils.pointToJson(point));
            }

            Weight weight = route.getMetadata().getWeight();
            Map<String, Object> resultWeight = new HashMap<>();
            resultWeight.put("time", Utils.localizedValueToJson(weight.getTime()));
            resultWeight.put("distance", Utils.localizedValueToJson(weight.getWalkingDistance()));
            resultWeight.put("transfersCount", weight.getTransfersCount());
            Map<String, Object> resultMetadata = new HashMap<>();
            resultMetadata.put("weight", resultWeight);

            Map<String, Object> resultRoute = new HashMap<>();
            resultRoute.put("geometry", resultPoints);
            resultRoute.put("metadata", resultMetadata);

            resultRoutes.add(resultRoute);
        }

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("routes", resultRoutes);

        result.success(resultMap);
    }

    @Override
    public void onMasstransitRoutesError(@NonNull Error error) {
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
}