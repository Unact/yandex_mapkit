package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;

import com.yandex.mapkit.MapKitFactory;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class YandexMapkitPlugin implements FlutterPlugin, ActivityAware {
  private static final String VIEW_TYPE = "yandex_mapkit/yandex_map";
  private static final String SEARCH_CHANNEL_ID   = "yandex_mapkit/yandex_search";
  private static final String SUGGEST_CHANNEL_ID  = "yandex_mapkit/yandex_suggest";
  private static final String DRIVING_CHANNEL_ID  = "yandex_mapkit/yandex_driving";
  private static final String BICYCLE_CHANNEL_ID  = "yandex_mapkit/yandex_bicycle";

  @Nullable private Lifecycle lifecycle;

  @Nullable private MethodChannel searchMethodChannel;
  @Nullable private MethodChannel suggestMethodChannel;
  @Nullable private MethodChannel drivingMethodChannel;
  @Nullable private MethodChannel bicycleMethodChannel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    MapKitFactory.initialize(binding.getApplicationContext());

    BinaryMessenger messenger = binding.getBinaryMessenger();
    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(messenger, new LifecycleProvider()));

    setupChannels(messenger, binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    teardownChannels();
  }

  private void setupChannels(BinaryMessenger messenger, Context context) {
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
  }

  @SuppressWarnings({"ConstantConditions"})
  private void teardownChannels() {
    searchMethodChannel.setMethodCallHandler(null);
    searchMethodChannel = null;

    suggestMethodChannel.setMethodCallHandler(null);
    suggestMethodChannel = null;

    drivingMethodChannel.setMethodCallHandler(null);
    drivingMethodChannel = null;

    bicycleMethodChannel.setMethodCallHandler(null);
    bicycleMethodChannel = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    MapKitFactory.getInstance().onStart();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle = null;
    MapKitFactory.getInstance().onStop();
  }

  public class LifecycleProvider {
    @Nullable
    Lifecycle getLifecycle() {
      return lifecycle;
    }
  }
}
