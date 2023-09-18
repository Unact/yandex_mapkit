package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManager;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.SuggestSession;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSuggest implements MethodCallHandler {
    private final SearchManager searchManager;
    private final BinaryMessenger binaryMessenger;
    @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
    private final Map<Integer, YandexSuggestSession> suggestSessions = new HashMap<>();

    public YandexSuggest(Context context, BinaryMessenger messenger) {
        SearchFactory.initialize(context);

        searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
        binaryMessenger = messenger;
    }

    @Override
    @SuppressWarnings({"SwitchStatementWithTooFewBranches"})
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getSuggestions":
                getSuggestions(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @SuppressWarnings({"unchecked", "ConstantConditions"})
    private void getSuggestions(MethodCall call, Result result) {
        Map<String, Object> params = ((Map<String, Object>) call.arguments);
        final int sessionId = ((Number) params.get("sessionId")).intValue();
        SuggestSession session = searchManager.createSuggestSession();

        session.suggest(
                (String) params.get("text"),
                Utils.boundingBoxFromJson((Map<String, Object>) params.get("boundingBox")),
                Utils.suggestOptionsFromJson((Map<String, Object>) params.get("suggestOptions")),
                new YandexSuggestListener(result)
        );

        YandexSuggestSession suggestSession = new YandexSuggestSession(
                sessionId,
                session,
                binaryMessenger,
                new SuggestCloseListener()
        );

        suggestSessions.put(sessionId, suggestSession);
    }

    public class SuggestCloseListener {
        public void onClose(int id) {
            suggestSessions.remove(id);
        }
    }
}
