package com.unact.yandexmapkit;

import android.app.Activity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.yandex.mapkit.MapKitFactory;

public class YandexMapkitPlugin implements MethodCallHandler {
  static MethodChannel channel;
  private Activity activity;


  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "yandex_mapkit");
    final YandexMapkitPlugin instance = new YandexMapkitPlugin(registrar.activity());

    channel.setMethodCallHandler(instance);
    registrar.platformViewRegistry().registerViewFactory(
      "yandex_mapkit/yandex_map",
       new YandexMapFactory(registrar)
    );
  }

  private YandexMapkitPlugin(Activity activity) {
    this.activity = activity;
  }

}
