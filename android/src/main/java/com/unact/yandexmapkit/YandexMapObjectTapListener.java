package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectTapListener;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

public class YandexMapObjectTapListener implements MapObjectTapListener {
  private final WeakReference<YandexMapController> controller;
  final String id;

  public YandexMapObjectTapListener(String id, WeakReference<YandexMapController> controller) {
    this.id = id;
    this.controller = controller;
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("point", Utils.pointToJson(point));

    controller.get().methodChannel.invokeMethod("onMapObjectTap", arguments);

    return false;
  }
}
