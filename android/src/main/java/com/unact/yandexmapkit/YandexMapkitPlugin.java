package com.unact.yandexmapkit;

import android.app.Activity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.yandex.mapkit.MapKitFactory;

public class YandexMapkitPlugin {

  public static void registerWith(Registrar registrar) {
    registrar.platformViewRegistry().registerViewFactory(
      "yandex_mapkit/yandex_map",
       new YandexMapFactory(registrar)
    );

    YandexSearch.registerWith(registrar);
  }

}
