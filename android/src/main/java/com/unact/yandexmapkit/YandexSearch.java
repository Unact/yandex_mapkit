package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManager;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.Session;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSearch implements MethodCallHandler {
    private final SearchManager searchManager;
    private final BinaryMessenger binaryMessenger;
    @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
    private final Map<Integer, YandexSearchSession> searchSessions = new HashMap<>();

    public YandexSearch(Context context, BinaryMessenger messenger) {
        SearchFactory.initialize(context);

        searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
        binaryMessenger = messenger;
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "searchByText":
                searchByText(call, result);
                break;
            case "searchByPoint":
                searchByPoint(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @SuppressWarnings({"unchecked", "ConstantConditions"})
    public void searchByText(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> params = ((Map<String, Object>) call.arguments);
        int sessionId = ((Number) params.get("sessionId")).intValue();
        Session session = searchManager.submit(
                (String) params.get("searchText"),
                Utils.geometryFromJson((Map<String, Object>) params.get("geometry")),
                Utils.searchOptionsFromJson((Map<String, Object>) params.get("searchOptions")),
                new YandexSearchListener(result, 0)
        );

        YandexSearchSession searchSession = new YandexSearchSession(
                sessionId,
                session,
                binaryMessenger,
                new SearchCloseListener()
        );

        searchSessions.put(sessionId, searchSession);
    }

    @SuppressWarnings({"unchecked", "ConstantConditions"})
    public void searchByPoint(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> params = ((Map<String, Object>) call.arguments);
        int sessionId = ((Number) params.get("sessionId")).intValue();
        Session session = searchManager.submit(
                Utils.pointFromJson((Map<String, Object>) params.get("point")),
                ((Integer) params.get("zoom")),
                Utils.searchOptionsFromJson((Map<String, Object>) params.get("searchOptions")),
                new YandexSearchListener(result, 0)
        );

        YandexSearchSession searchSession = new YandexSearchSession(
                sessionId,
                session,
                binaryMessenger,
                new SearchCloseListener()
        );

        searchSessions.put(sessionId, searchSession);
    }

    public class SearchCloseListener {
        public void onClose(int id) {
            searchSessions.remove(id);
        }
    }
}
