package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.transport.TransportFactory;
import com.yandex.mapkit.transport.bicycle.BicycleRouter;
import com.yandex.mapkit.transport.bicycle.Session;
import com.yandex.mapkit.transport.bicycle.VehicleType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexBicycle implements MethodCallHandler {
    private final BicycleRouter bicycleRouter;
    private final BinaryMessenger binaryMessenger;
    @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
    private final Map<Integer, YandexBicycleSession> bicycleSessions = new HashMap<>();

    public YandexBicycle(Context context, BinaryMessenger messenger) {
        TransportFactory.initialize(context);

        bicycleRouter = TransportFactory.getInstance().createBicycleRouter();
        binaryMessenger = messenger;
    }

    @Override
    @SuppressWarnings({"SwitchStatementWithTooFewBranches"})
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

    @SuppressWarnings({"unchecked", "ConstantConditions"})
    private void requestRoutes(final MethodCall call, final Result result) {
        Map<String, Object> params = (Map<String, Object>) call.arguments;
        Integer sessionId = (Integer) params.get("sessionId");
        List<RequestPoint> points = new ArrayList<>();
        for (Map<String, Object> pointParams : (List<Map<String, Object>>) params.get("points")) {
            points.add(Utils.requestPointFromJson(pointParams));
        }

        Session session = bicycleRouter.requestRoutes(
                points,
                VehicleType.values()[(Integer) params.get("bicycleVehicleType")],
                new YandexBicycleListener(result)
        );

        YandexBicycleSession bicycleSession = new YandexBicycleSession(
                sessionId,
                session,
                binaryMessenger,
                new BicycleCloseListener()
        );

        bicycleSessions.put(sessionId, bicycleSession);
    }

    public class BicycleCloseListener {
        public void onClose(int id) {
            bicycleSessions.remove(id);
        }
    }
}
