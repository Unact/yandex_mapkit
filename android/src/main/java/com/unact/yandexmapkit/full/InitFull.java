package com.unact.yandexmapkit.full;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.unact.yandexmapkit.lite.InitLite;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class InitFull extends InitLite {
  private static final String SEARCH_CHANNEL_ID   = "yandex_mapkit/yandex_search";
  private static final String SUGGEST_CHANNEL_ID  = "yandex_mapkit/yandex_suggest";
  private static final String DRIVING_CHANNEL_ID  = "yandex_mapkit/yandex_driving";
  private static final String BICYCLE_CHANNEL_ID  = "yandex_mapkit/yandex_bicycle";
  private static final String PEDESTRIAN_CHANNEL_ID  = "yandex_mapkit/yandex_pedestrian";

  @Nullable private MethodChannel searchMethodChannel;
  @Nullable private MethodChannel suggestMethodChannel;
  @Nullable private MethodChannel drivingMethodChannel;
  @Nullable private MethodChannel bicycleMethodChannel;
  @Nullable private MethodChannel pedestrianMethodChannel;

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    super.onAttachedToEngine(binding);

    setupChannels(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
    teardownChannels();
  }

  public void setupChannels(BinaryMessenger messenger, Context context) {
    searchMethodChannel = new MethodChannel(messenger, SEARCH_CHANNEL_ID);
    YandexSearch yandexSearch = new YandexSearch(context, messenger);
    searchMethodChannel.setMethodCallHandler(yandexSearch);

    suggestMethodChannel = new MethodChannel(messenger, SUGGEST_CHANNEL_ID);
    YandexSuggest yandexSuggest = new YandexSuggest(context, messenger);
    suggestMethodChannel.setMethodCallHandler(yandexSuggest);

    drivingMethodChannel = new MethodChannel(messenger, DRIVING_CHANNEL_ID);
    YandexDriving yandexDriving = new YandexDriving(context, messenger);
    drivingMethodChannel.setMethodCallHandler(yandexDriving);

    bicycleMethodChannel = new MethodChannel(messenger, BICYCLE_CHANNEL_ID);
    YandexBicycle yandexBicycle = new YandexBicycle(context, messenger);
    bicycleMethodChannel.setMethodCallHandler(yandexBicycle);

    pedestrianMethodChannel = new MethodChannel(messenger, PEDESTRIAN_CHANNEL_ID);
    YandexPedestrian yandexPedestrian = new YandexPedestrian(context, messenger);
    pedestrianMethodChannel.setMethodCallHandler(yandexPedestrian);
  }

  @SuppressWarnings({"ConstantConditions"})
  public void teardownChannels() {
    searchMethodChannel.setMethodCallHandler(null);
    searchMethodChannel = null;

    suggestMethodChannel.setMethodCallHandler(null);
    suggestMethodChannel = null;

    drivingMethodChannel.setMethodCallHandler(null);
    drivingMethodChannel = null;

    bicycleMethodChannel.setMethodCallHandler(null);
    bicycleMethodChannel = null;

    pedestrianMethodChannel.setMethodCallHandler(null);
    pedestrianMethodChannel = null;
  }
}
