package com.unact.yandexmapkit;

import android.content.Context;

import com.yandex.mapkit.MapKitFactory;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class YandexMapkitPlugin implements FlutterPlugin {
  private static final String VIEW_TYPE = "yandex_mapkit/yandex_map";
  private static final String CHANNEL_ID = "yandex_mapkit/yandex_search";

  private MethodChannel methodChannel;
  private YandexSearchHandlerImpl handler;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    MapKitFactory.initialize(binding.getApplicationContext());
    MapKitFactory.getInstance().onStart();

    BinaryMessenger messenger = binding.getBinaryMessenger();
    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(messenger));

    setupYandexSearchChannel(messenger, binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownYandexSearchChannel();
    MapKitFactory.getInstance().onStop();
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
