package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.search.SuggestItem;
import com.yandex.mapkit.search.SuggestType;
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
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSearchHandlerImpl implements MethodCallHandler {
  private MethodChannel methodChannel;
  private Map<Integer, SuggestSession> suggestSessionsById = new HashMap<>();
  private final SearchManager searchManager;

  public YandexSearchHandlerImpl(Context context, MethodChannel channel) {
    SearchFactory.initialize(context);
    methodChannel = channel;
    searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
  }

  @SuppressWarnings("unchecked")
  private void cancelSuggestSession(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    final int listenerId = ((Number) params.get("listenerId")).intValue();
    suggestSessionsById.remove(listenerId);
  }

  @SuppressWarnings("unchecked")
  private void getSuggestions(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    final int listenerId = ((Number) params.get("listenerId")).intValue();

    String formattedAddress = (String) params.get("formattedAddress");
    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) params.get("southWestLatitude")), ((Double) params.get("southWestLongitude"))),
      new Point(((Double) params.get("northEastLatitude")), ((Double) params.get("northEastLongitude")))
    );
    SuggestType suggestType;
    switch ((String) params.get("suggestType")) {
      case "GEO":
        suggestType = SuggestType.GEO;
        break;
      case "BIZ":
        suggestType = SuggestType.BIZ;
        break;
      case "TRANSIT":
        suggestType = SuggestType.TRANSIT;
        break;
      default:
        suggestType = SuggestType.UNSPECIFIED;
        break;
    }
    Boolean suggestWords = ((Boolean) params.get("suggestWords"));
    SuggestSession suggestSession = searchManager.createSuggestSession();
    SuggestOptions suggestOptions = new SuggestOptions();
    suggestOptions.setSuggestTypes(suggestType.value);
    suggestOptions.setSuggestWords(suggestWords);
    suggestSession.suggest(formattedAddress, boundingBox, suggestOptions, new YandexSuggestListener(listenerId));
    suggestSessionsById.put(listenerId, suggestSession);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "getSuggestions":
        getSuggestions(call);
        result.success(null);
        break;
      case "cancelSuggestSession":
        cancelSuggestSession(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private class YandexSuggestListener implements SuggestSession.SuggestListener {
    public YandexSuggestListener(int id) {
      listenerId = id;
    }
    private int listenerId;

    @Override
    public void onResponse(@NonNull List<SuggestItem> suggestItems) {
      List<Map<String, Object>> suggests = new ArrayList<>();

      for (SuggestItem suggestItemResult : suggestItems) {
        Map<String, Object> suggestMap = new HashMap<>();
        suggestMap.put("title", suggestItemResult.getTitle().getText());
        if(suggestItemResult.getSubtitle() != null) {
          suggestMap.put("subtitle", suggestItemResult.getSubtitle().getText());
        }
        if(suggestItemResult.getDisplayText() != null) {
          suggestMap.put("displayText", suggestItemResult.getDisplayText());
        }
        suggestMap.put("searchText", suggestItemResult.getSearchText());
        suggestMap.put("tags", suggestItemResult.getTags());
        String suggestItemType;
        switch (suggestItemResult.getType()) {
          case TOPONYM:
            suggestItemType = "TOPONYM";
            break;
          case BUSINESS:
            suggestItemType = "BUSINESS";
            break;
          case TRANSIT:
            suggestItemType = "TRANSIT";
            break;
          default:
            suggestItemType = "UNKNOWN";
            break;
        }
        suggestMap.put("type", suggestItemType);
        suggests.add(suggestMap);
      }

      Map<String, Object> arguments = new HashMap<>();
      arguments.put("listenerId", listenerId);
      arguments.put("response", suggests);
      methodChannel.invokeMethod("onSuggestListenerResponse", arguments);
    }

    @Override
    public void onError(@NonNull Error error) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("listenerId", listenerId);
      methodChannel.invokeMethod("onSuggestListenerError", arguments);
    }
  }
}
