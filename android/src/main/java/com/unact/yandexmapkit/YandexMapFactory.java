package com.unact.yandexmapkit;

import android.content.Context;

import static io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YandexMapFactory extends PlatformViewFactory {
  private final Registrar pluginRegistrar;

  public YandexMapFactory(Registrar registrar) {
    super(StandardMessageCodec.INSTANCE);
    pluginRegistrar = registrar;
  }

  @Override
  public PlatformView create(Context context, int id, Object o) {
    return new YandexMapController(id, context, pluginRegistrar);
  }
}
