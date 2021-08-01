package com.unact.yandexmapkit;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class YandexMapkitPlugin implements FlutterPlugin {
  private static final String VIEW_TYPE = "yandex_mapkit/yandex_map";
  private static final String SEARCH_CHANNEL_ID = "yandex_mapkit/yandex_search";
  private static final String DRIVING_CHANNEL_ID = "yandex_mapkit/yandex_driving";

  private MethodChannel methodChannelSearch;
  private MethodChannel methodChannelDrivingRouter;

  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }

    registrar.platformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(registrar.messenger()));

    new YandexMapkitPlugin().setupChannels(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    BinaryMessenger messenger = binding.getBinaryMessenger();
    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(messenger));

    setupChannels(messenger, binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownChannels();
  }

  private void setupChannels(BinaryMessenger messenger, Context context) {
    methodChannelSearch = new MethodChannel(messenger, SEARCH_CHANNEL_ID);
    YandexSearchHandlerImpl handlerSearch = new YandexSearchHandlerImpl(context);
    methodChannelSearch.setMethodCallHandler(handlerSearch);

    methodChannelDrivingRouter = new MethodChannel(messenger, DRIVING_CHANNEL_ID);
    YandexDrivingRouterHandlerImpl handlerDrivingRouter = new YandexDrivingRouterHandlerImpl(context);
    methodChannelDrivingRouter.setMethodCallHandler(handlerDrivingRouter);

  }

  private void teardownChannels() {
    methodChannelSearch.setMethodCallHandler(null);
    methodChannelSearch = null;

    methodChannelDrivingRouter.setMethodCallHandler(null);
    methodChannelDrivingRouter = null;
  }
}
