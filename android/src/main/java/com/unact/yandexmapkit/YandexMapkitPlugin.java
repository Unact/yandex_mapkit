package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class YandexMapkitPlugin implements FlutterPlugin, ActivityAware {
  private final Init variantInit;

  public YandexMapkitPlugin() throws IllegalAccessException, InstantiationException {
    this.variantInit = (Init) BuildConfig.YANDEX_MAPKIT_INIT_CLASS.newInstance();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    variantInit.onAttachedToEngine(binding);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    variantInit.onDetachedFromEngine(binding);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    variantInit.onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    variantInit.onDetachedFromActivityForConfigChanges();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    variantInit.onReattachedToActivityForConfigChanges(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    variantInit.onDetachedFromActivity();
  }
}
