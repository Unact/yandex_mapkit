package com.unact.yandexmapkit;

import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PolylineMapObject;

import java.lang.ref.WeakReference;
import java.util.Map;

public class YandexPolylineController extends YandexMapObjectController {
  public final PolylineMapObject polyline;
  private final YandexMapObjectTapListener tapListener;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  public YandexPolylineController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    PolylineMapObject polyline = parent.addPolyline(Utils.polylineFromJson(params));

    this.polyline = polyline;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);

    polyline.addTapListener(tapListener);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));

    polyline.setGeodesic((boolean) params.get("isGeodesic"));
    polyline.setZIndex(((Double) params.get("zIndex")).floatValue());
    polyline.setOutlineColor(((Number) style.get("outlineColor")).intValue());
    polyline.setOutlineWidth(((Double) style.get("outlineWidth")).floatValue());
    polyline.setStrokeColor(((Number) style.get("strokeColor")).intValue());
    polyline.setStrokeWidth(((Double) style.get("strokeWidth")).floatValue());
    polyline.setDashLength(((Double) style.get("dashLength")).floatValue());
    polyline.setDashOffset(((Double) style.get("dashOffset")).floatValue());
    polyline.setGapLength(((Double) style.get("gapLength")).floatValue());
    polyline.setGeometry(Utils.polylineFromJson(params));
  }

  public void remove() {
    polyline.getParent().remove(polyline);
  }
}
