package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.search.SuggestSession;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class YandexSuggestSession implements MethodChannel.MethodCallHandler {
    private final int id;
    private final SuggestSession session;
    private final MethodChannel methodChannel;
    private final YandexSuggest.SuggestCloseListener closeListener;

    public YandexSuggestSession(
            int id,
            SuggestSession session,
            BinaryMessenger messenger,
            YandexSuggest.SuggestCloseListener closeListener
    ) {
        this.id = id;
        this.session = session;
        this.closeListener = closeListener;

        methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_suggest_session_" + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "reset":
                reset();
                result.success(null);
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

    public void reset() {
        session.reset();
    }

    public void close() {
        session.reset();
        methodChannel.setMethodCallHandler(null);

        closeListener.onClose(id);
    }
}
