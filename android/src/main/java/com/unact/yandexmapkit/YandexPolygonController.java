package com.unact.yandexmapkit;

import android.content.Context;

import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PolygonMapObject;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexPolygonController extends YandexMapObjectController {
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final Context context;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final MethodChannel methodChannel;
  private final PolygonMapObject polygon;
  private final MapObjectCollection parent;
  public final String id;

  public YandexPolygonController(
    MapObjectCollection parent,
    Map<String, Object> params,
    MethodChannel methodChannel,
    Context context
  ) {
    PolygonMapObject polygon = parent.addPolygon(Utils.polygonFromJson(params));

    this.polygon = polygon;
    this.id = (String) params.get("id");
    this.parent = parent;
    this.context = context;
    this.methodChannel = methodChannel;

    polygon.addTapListener(new YandexMapObjectTapListener(id, methodChannel));
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));

    polygon.setGeodesic((boolean) params.get("isGeodesic"));
    polygon.setZIndex(((Double) params.get("zIndex")).floatValue());
    polygon.setGeodesic((boolean) params.get("isGeodesic"));
    polygon.setStrokeWidth(((Double) style.get("strokeWidth")).floatValue());
    polygon.setStrokeColor(((Number) style.get("strokeColor")).intValue());
    polygon.setFillColor(((Number) style.get("fillColor")).intValue());
    polygon.setGeometry(Utils.polygonFromJson(params));
  }

  public void remove(Map<String, Object> params) {
    parent.remove(polygon);
  }
}
