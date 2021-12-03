package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectDragListener;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

public class YandexMapObjectDragListener implements MapObjectDragListener {
  private final WeakReference<YandexMapController> controller;
  final String id;

  public YandexMapObjectDragListener(String id, WeakReference<YandexMapController> controller) {
    this.id = id;
    this.controller = controller;
  }

  @Override
  public void onMapObjectDragStart(@NonNull MapObject mapObject) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);

    controller.get().methodChannel.invokeMethod("onMapObjectDragStart", arguments);
  }

  @Override
  public void onMapObjectDrag(@NonNull MapObject mapObject, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("point", Utils.pointToJson(point));

    controller.get().methodChannel.invokeMethod("onMapObjectDrag", arguments);
  }

  @Override
  public void onMapObjectDragEnd(@NonNull MapObject mapObject) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);

    controller.get().methodChannel.invokeMethod("onMapObjectDragEnd", arguments);
  }
}
