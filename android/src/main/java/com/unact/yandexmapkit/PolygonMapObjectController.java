package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PolygonMapObject;

import java.lang.ref.WeakReference;
import java.util.Map;

public class PolygonMapObjectController extends MapObjectController implements MapObjectTapListener {
  public final PolygonMapObject polygon;
  private boolean consumeTapEvents = false;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"ConstantConditions", "unchecked"})
  public PolygonMapObjectController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    PolygonMapObject polygon = parent.addPolygon(
      Utils.polygonFromJson((Map<String, Object>) params.get("polygon"))
    );

    this.polygon = polygon;
    this.id = (String) params.get("id");
    this.controller = controller;

    polygon.setUserData(this.id);
    polygon.addTapListener(this);
    update(params);
  }

  @SuppressWarnings({"ConstantConditions", "unchecked"})
  public void update(Map<String, Object> params) {
    polygon.setGeometry(Utils.polygonFromJson((Map<String, Object>) params.get("polygon")));
    polygon.setGeodesic((Boolean) params.get("isGeodesic"));
    polygon.setZIndex(((Double) params.get("zIndex")).floatValue());
    polygon.setVisible((Boolean) params.get("isVisible"));
    polygon.setStrokeWidth(((Double) params.get("strokeWidth")).floatValue());
    polygon.setStrokeColor(((Number) params.get("strokeColor")).intValue());
    polygon.setFillColor(((Number) params.get("fillColor")).intValue());

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
  }

  public void remove() {
    polygon.getParent().remove(polygon);
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectTap(id, point);

    return consumeTapEvents;
  }
}
