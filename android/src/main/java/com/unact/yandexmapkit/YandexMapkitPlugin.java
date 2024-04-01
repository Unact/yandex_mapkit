package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class YandexMapkitPlugin implements FlutterPlugin, ActivityAware {
  private final Init variantInit;

  public YandexMapkitPlugin() throws ClassNotFoundException, IllegalAccessException, InstantiationException {
    String name = "com.unact.yandexmapkit." + BuildConfig.YANDEX_MAPKIT + ".Init" +
      BuildConfig.YANDEX_MAPKIT.substring(0, 1).toUpperCase() + BuildConfig.YANDEX_MAPKIT.substring(1);

    this.variantInit = (Init) Class.forName(name).newInstance();
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
