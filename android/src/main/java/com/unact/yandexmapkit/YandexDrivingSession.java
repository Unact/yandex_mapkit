package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.directions.driving.DrivingSession;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class YandexDrivingSession implements MethodChannel.MethodCallHandler {
    private final int id;
    private final DrivingSession session;
    private final MethodChannel methodChannel;
    private final YandexDriving.DrivingCloseListener closeListener;

    public YandexDrivingSession(
            int id,
            DrivingSession session,
            BinaryMessenger messenger,
            YandexDriving.DrivingCloseListener closeListener
    ) {
        this.id = id;
        this.session = session;
        this.closeListener = closeListener;

        methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_driving_session_" + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
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

    public void cancel() {
        session.cancel();
    }

    public void retry(MethodChannel.Result result) {
        session.retry(new YandexDrivingListener(result));
    }

    public void close() {
        session.cancel();
        methodChannel.setMethodCallHandler(null);

        closeListener.onClose(id);
    }
}
