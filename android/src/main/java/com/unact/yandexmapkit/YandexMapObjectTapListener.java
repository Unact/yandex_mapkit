package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectTapListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexMapObjectTapListener implements MapObjectTapListener {
  final MethodChannel methodChannel;
  final String id;

  public YandexMapObjectTapListener(String id, MethodChannel methodChannel) {
    this.id = id;
    this.methodChannel = methodChannel;
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("point", Utils.pointToJson(point));

    methodChannel.invokeMethod("onMapObjectTap", arguments);

    return true;
  }
}
