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
  private static final String CHANNEL_ID = "yandex_mapkit/yandex_search";

  @Nullable private Lifecycle lifecycle;

  private MethodChannel methodChannel;
  private YandexSearchHandlerImpl handler;
  
  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    MapKitFactory.initialize(binding.getApplicationContext());

    BinaryMessenger messenger = binding.getBinaryMessenger();
    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(messenger, new LifecycleProvider()));

    setupYandexSearchChannel(messenger, binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownYandexSearchChannel();
  }

  private void setupYandexSearchChannel(BinaryMessenger messenger, Context context) {
    methodChannel = new MethodChannel(messenger, CHANNEL_ID);
    handler = new YandexSearchHandlerImpl(context, methodChannel);
    methodChannel.setMethodCallHandler(handler);
  }

  private void teardownYandexSearchChannel() {
    methodChannel.setMethodCallHandler(null);
    handler = null;
    methodChannel = null;
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
    };
  }
}
