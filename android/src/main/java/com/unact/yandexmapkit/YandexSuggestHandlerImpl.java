package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.search.SuggestItem;
import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.SuggestOptions;
import com.yandex.mapkit.search.SearchManager;
import com.yandex.mapkit.search.SuggestSession;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSuggestHandlerImpl implements MethodCallHandler {

  private final Map<Integer, SuggestSession> suggestSessionsById = new HashMap<>();
  private final SearchManager searchManager;

  public YandexSuggestHandlerImpl(Context context) {
    SearchFactory.initialize(context);
    searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getSuggestions":
        getSuggestions(call, result);
        break;
      case "cancelSuggestSession":
        cancelSuggestSession(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings("unchecked")
  private void cancelSuggestSession(MethodCall call, Result result) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    final int listenerId = ((Number) params.get("listenerId")).intValue();

    final SuggestSession session = suggestSessionsById.remove(listenerId);

    if (session != null) {
      session.reset();
    }

    result.success(null);
  }

  @SuppressWarnings("unchecked")
  private void getSuggestions(MethodCall call, Result result) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    final int listenerId = ((Number) params.get("listenerId")).intValue();

    String formattedAddress = (String) params.get("formattedAddress");

    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) params.get("southWestLatitude")), ((Double) params.get("southWestLongitude"))),
      new Point(((Double) params.get("northEastLatitude")), ((Double) params.get("northEastLongitude")))
    );

    Boolean suggestWords = ((Boolean) params.get("suggestWords"));

    SuggestSession suggestSession = searchManager.createSuggestSession();

    SuggestOptions suggestOptions = new SuggestOptions();
    suggestOptions.setSuggestTypes(((Number) params.get("suggestType")).intValue());
    suggestOptions.setSuggestWords(suggestWords);

    suggestSession.suggest(formattedAddress, boundingBox, suggestOptions, new YandexSuggestListener(listenerId, result));

    suggestSessionsById.put(listenerId, suggestSession);
  }

  private class YandexSuggestListener implements SuggestSession.SuggestListener {

    public YandexSuggestListener(int id, Result result) {
      listenerId = id;
      this.result = result;
    }

    private final int listenerId;
    private final Result result;

    @Override
    public void onResponse(@NonNull List<SuggestItem> suggestItems) {

      suggestSessionsById.remove(listenerId);
      List<Map<String, Object>> suggests = new ArrayList<>();

      for (SuggestItem suggestItemResult : suggestItems) {
        Map<String, Object> suggestMap = new HashMap<>();
        suggestMap.put("title", suggestItemResult.getTitle().getText());
        if (suggestItemResult.getSubtitle() != null) {
          suggestMap.put("subtitle", suggestItemResult.getSubtitle().getText());
        }
        if (suggestItemResult.getDisplayText() != null) {
          suggestMap.put("displayText", suggestItemResult.getDisplayText());
        }
        suggestMap.put("searchText", suggestItemResult.getSearchText());
        suggestMap.put("type", suggestItemResult.getType().ordinal());
        suggestMap.put("tags", suggestItemResult.getTags());

        suggests.add(suggestMap);
      }

      Map<String, Object> arguments = new HashMap<>();
      arguments.put("items", suggests);
      result.success(arguments);
    }

    @Override
    public void onError(@NonNull Error error) {
      suggestSessionsById.remove(listenerId);
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("error", error.getClass().getName());
      result.success(arguments);
    }
  }
}