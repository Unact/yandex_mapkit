package com.unact.yandexmapkit;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class YandexMapkitPlugin implements FlutterPlugin {
  private static final String VIEW_TYPE = "yandex_mapkit/yandex_map";
  private static final String CHANNEL_ID = "yandex_mapkit/yandex_search";

  private MethodChannel methodChannel;
  private YandexSearchHandlerImpl handler;

  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }

    registrar.platformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(registrar.messenger()));

    new YandexMapkitPlugin().setupYandexSearchChannel(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    BinaryMessenger messenger = binding.getBinaryMessenger();
    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(messenger));

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
}
