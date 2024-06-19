package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class YandexMapkitPlugin implements FlutterPlugin, ActivityAware {

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    BuildConfig.YANDEX_MAPKIT_INIT.onAttachedToEngine(binding);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    BuildConfig.YANDEX_MAPKIT_INIT.onDetachedFromEngine(binding);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    BuildConfig.YANDEX_MAPKIT_INIT.onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    BuildConfig.YANDEX_MAPKIT_INIT.onDetachedFromActivityForConfigChanges();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    BuildConfig.YANDEX_MAPKIT_INIT.onReattachedToActivityForConfigChanges(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    BuildConfig.YANDEX_MAPKIT_INIT.onDetachedFromActivity();
  }
}
