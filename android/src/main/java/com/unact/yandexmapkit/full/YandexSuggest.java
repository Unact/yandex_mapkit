package com.unact.yandexmapkit.full;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.SearchManager;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSuggest implements MethodCallHandler {
  private final SearchManager searchManager;
  private final BinaryMessenger binaryMessenger;

  public YandexSuggest(Context context, BinaryMessenger messenger) {
    searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
    binaryMessenger = messenger;
  }

  @Override
  @SuppressWarnings({"SwitchStatementWithTooFewBranches"})
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "initSession":
        initSession(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void initSession(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    final int id = ((Number) params.get("id")).intValue();

    YandexSuggestSession.initSession(id, binaryMessenger, searchManager);
  }
}
