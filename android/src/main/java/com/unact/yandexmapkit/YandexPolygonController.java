package com.unact.yandexmapkit;

import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PolygonMapObject;

import java.lang.ref.WeakReference;
import java.util.Map;

public class YandexPolygonController extends YandexMapObjectController {
  public final PolygonMapObject polygon;
  private final YandexMapObjectTapListener tapListener;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  public YandexPolygonController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    PolygonMapObject polygon = parent.addPolygon(Utils.polygonFromJson(params));

    this.polygon = polygon;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);

    polygon.setUserData(this.id);
    polygon.addTapListener(tapListener);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));

    polygon.setZIndex(((Double) params.get("zIndex")).floatValue());
    polygon.setStrokeWidth(((Double) style.get("strokeWidth")).floatValue());
    polygon.setStrokeColor(((Number) style.get("strokeColor")).intValue());
    polygon.setFillColor(((Number) style.get("fillColor")).intValue());
    polygon.setGeometry(Utils.polygonFromJson(params));
    polygon.setGeodesic((Boolean) params.get("isGeodesic"));
    polygon.setVisible((Boolean) params.get("isVisible"));
  }

  public void remove() {
    polygon.getParent().remove(polygon);
  }
}
