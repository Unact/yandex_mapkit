package com.unact.yandexmapkit;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class YandexMapkitPlugin implements FlutterPlugin {

  private static final String VIEW_TYPE = "yandex_mapkit/yandex_map";

  private static final String SEARCH_CHANNEL_ID = "yandex_mapkit/yandex_search";
  private static final String SUGGEST_CHANNEL_ID = "yandex_mapkit/yandex_suggest";

  private MethodChannel searchMethodChannel;
  private MethodChannel suggestMethodChannel;

  private YandexSearchHandlerImpl2   searchHandler;
  private YandexSearchHandlerImpl  suggestHandler;

  public static void registerWith(Registrar registrar) {

    if (registrar.activity() == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }

    registrar.platformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(registrar.messenger()));

    YandexMapkitPlugin plugin = new YandexMapkitPlugin();

    plugin.setupYandexSearchChannel(registrar.messenger(), registrar.context());
    plugin.setupYandexSuggestChannel(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {

    BinaryMessenger messenger = binding.getBinaryMessenger();

    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE, new YandexMapFactory(messenger));

    setupYandexSearchChannel(messenger, binding.getApplicationContext());
    setupYandexSuggestChannel(messenger, binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownYandexSearchChannel();
    teardownYandexSuggestChannel();
  }

  private void setupYandexSearchChannel(BinaryMessenger messenger, Context context) {

    searchMethodChannel = new MethodChannel(messenger, SEARCH_CHANNEL_ID);

    searchHandler = new YandexSearchHandlerImpl2(context, messenger);

    searchMethodChannel.setMethodCallHandler(searchHandler);
  }

  private void setupYandexSuggestChannel(BinaryMessenger messenger, Context context) {

    suggestMethodChannel = new MethodChannel(messenger, SUGGEST_CHANNEL_ID);

    suggestHandler = new YandexSearchHandlerImpl(context, suggestMethodChannel);

    suggestMethodChannel.setMethodCallHandler(suggestHandler);
  }

  private void teardownYandexSearchChannel() {

    searchMethodChannel.setMethodCallHandler(null);
    searchHandler = null;
    searchMethodChannel = null;
  }

  private void teardownYandexSuggestChannel() {

    suggestMethodChannel.setMethodCallHandler(null);
    suggestHandler = null;
    suggestMethodChannel = null;
  }
}
