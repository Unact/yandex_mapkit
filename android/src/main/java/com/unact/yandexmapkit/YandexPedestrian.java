package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.transport.TransportFactory;
import com.yandex.mapkit.transport.masstransit.PedestrianRouter;
import com.yandex.mapkit.transport.masstransit.Session;
import com.yandex.mapkit.transport.masstransit.TimeOptions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class YandexPedestrian implements MethodCallHandler {
    private final PedestrianRouter pedestrianRouter;
    private final BinaryMessenger binaryMessenger;
    @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
    private final Map<Integer, YandexPedestrianSession> pedestrianSessions = new HashMap<>();

    public YandexPedestrian(Context context, BinaryMessenger messenger) {
        TransportFactory.initialize(context);

        pedestrianRouter = TransportFactory.getInstance().createPedestrianRouter();
        binaryMessenger = messenger;
    }

    @Override
    @SuppressWarnings({"SwitchStatementWithTooFewBranches"})
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "requestRoutes":
                requestRoutes(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    // public Session requestRoutes
    // (Point source, Point destination, TimeOptions timeOptions, RouteListener routeListener)
    @SuppressWarnings({"unchecked", "ConstantConditions"})
    private void requestRoutes(final MethodCall call, final MethodChannel.Result result) {
        Map<String, Object> params = (Map<String, Object>) call.arguments;
        Integer sessionId = (Integer) params.get("sessionId");

        List<RequestPoint> points = new ArrayList<>();
        for (Map<String, Object> pointParams : (List<Map<String, Object>>) params.get("points")) {
            points.add(Utils.requestPointFromJson(pointParams));
        }

        Session session = pedestrianRouter.requestRoutes(
                points,
                //(TimeOptions) params.get("timeOptions"),
                new TimeOptions(),
                new YandexPedestrianListener(result)
        );

        YandexPedestrianSession pedestrianSession = new YandexPedestrianSession(
                sessionId,
                session,
                binaryMessenger,
                new YandexPedestrian.PedestrianCloseListener()
        );

        pedestrianSessions.put(sessionId, pedestrianSession);
    }

    public class PedestrianCloseListener {
        public void onClose(int id) {
            pedestrianSessions.remove(id);
        }
    }
}