package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.directions.DirectionsFactory;
import com.yandex.mapkit.directions.driving.DrivingRouter;
import com.yandex.mapkit.directions.driving.DrivingSession;
import com.yandex.mapkit.directions.driving.VehicleOptions;

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
    @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
    private final Map<Integer, YandexDrivingSession> drivingSessions = new HashMap<>();

    public YandexDriving(Context context, BinaryMessenger messenger) {
        DirectionsFactory.initialize(context);

        drivingRouter = DirectionsFactory.getInstance().createDrivingRouter();
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

        DrivingSession session = drivingRouter.requestRoutes(
                points,
                Utils.drivingOptionsFromJson((Map<String, Object>) params.get("drivingOptions")),
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

    public class DrivingCloseListener {
        public void onClose(int id) {
            drivingSessions.remove(id);
        }
    }
}
