package com.unact.yandexmapkit.lite;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;

import com.unact.yandexmapkit.Init;
import com.yandex.mapkit.MapKitFactory;


import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.BinaryMessenger;

public class InitLite extends Init {
  private static final String VIEW_TYPE = "yandex_mapkit/yandex_map";

  @Nullable private Lifecycle lifecycle;

  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    MapKitFactory.initialize(binding.getApplicationContext());

    BinaryMessenger messenger = binding.getBinaryMessenger();
    binding.getPlatformViewRegistry().registerViewFactory(
        VIEW_TYPE,
        new YandexMapFactory(messenger, new LifecycleProvider())
    );
  }

  public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {}

  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    MapKitFactory.getInstance().onStart();
  }

  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  public void onDetachedFromActivity() {
    lifecycle = null;
    MapKitFactory.getInstance().onStop();
  }

  public class LifecycleProvider {
    @Nullable
    public Lifecycle getLifecycle() {
      return lifecycle;
    }
  }
}
