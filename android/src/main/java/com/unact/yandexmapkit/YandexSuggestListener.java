package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.search.SuggestItem;
import com.yandex.mapkit.search.SuggestSession;
import com.yandex.runtime.Error;
import com.yandex.runtime.network.NetworkError;
import com.yandex.runtime.network.RemoteError;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexSuggestListener implements SuggestSession.SuggestListener {
  private final MethodChannel.Result result;

  public YandexSuggestListener(MethodChannel.Result result) {
    this.result = result;
  }

  @Override
  public void onResponse(@NonNull List<SuggestItem> suggestItems) {
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
    String errorMessage = "Unknown error";

    if (error instanceof NetworkError) {
      errorMessage = "Network error";
    }

    if (error instanceof RemoteError) {
      errorMessage = "Remote server error";
    }

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("error", errorMessage);

    result.success(arguments);
  }
}