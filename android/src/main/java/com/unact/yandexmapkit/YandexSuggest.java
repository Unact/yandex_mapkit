package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.SuggestOptions;
import com.yandex.mapkit.search.SearchManager;
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
  private Map<Integer, YandexSuggestSession> suggestSessions  = new HashMap<>();

  public YandexSuggest(Context context, BinaryMessenger messenger) {
    SearchFactory.initialize(context);

    searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
    binaryMessenger = messenger;
  }

  @Override
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

  @SuppressWarnings("unchecked")
  private void getSuggestions(MethodCall call, Result result) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    final int sessionId = ((Number) params.get("sessionId")).intValue();
    String formattedAddress = (String) params.get("formattedAddress");
    Map<String, Object> paramsBoundingBox = (Map<String, Object>) params.get("boundingBox");
    Map<String, Object> southWest = (Map<String, Object>) paramsBoundingBox.get("southWest");
    Map<String, Object> northEast = (Map<String, Object>) paramsBoundingBox.get("northEast");
    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) southWest.get("latitude")), ((Double) southWest.get("longitude"))),
      new Point(((Double) northEast.get("latitude")), ((Double) northEast.get("longitude")))
    );

    Boolean suggestWords = ((Boolean) params.get("suggestWords"));

    SuggestSession session = searchManager.createSuggestSession();
    SuggestOptions suggestOptions = new SuggestOptions();
    suggestOptions.setSuggestTypes(((Number) params.get("suggestType")).intValue());
    suggestOptions.setSuggestWords(suggestWords);
    session.suggest(formattedAddress, boundingBox, suggestOptions, new YandexSuggestListener(result));

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
