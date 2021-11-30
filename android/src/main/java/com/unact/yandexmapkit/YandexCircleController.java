package com.unact.yandexmapkit;

import com.yandex.mapkit.map.CircleMapObject;
import com.yandex.mapkit.map.MapObjectCollection;

import java.lang.ref.WeakReference;
import java.util.Map;

public class YandexCircleController extends YandexMapObjectController {
  private final boolean internallyControlled;
  public final CircleMapObject circle;
  private final YandexMapObjectTapListener tapListener;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public YandexCircleController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    CircleMapObject circle = parent.addCircle(
      Utils.circleFromJson(params),
      ((Number) params.get("strokeColor")).intValue(),
      ((Double) params.get("strokeWidth")).floatValue(),
      ((Number) params.get("fillColor")).intValue()
    );

    this.circle = circle;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);
    this.internallyControlled = false;

    circle.setUserData(this.id);
    circle.addTapListener(tapListener);
    update(params);
  }

  public YandexCircleController(
    CircleMapObject circle,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    this.circle = circle;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);
    this.internallyControlled = true;

    circle.setUserData(id);
    circle.addTapListener(tapListener);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    circle.setGeometry(Utils.circleFromJson(params));
    circle.setGeodesic((Boolean) params.get("isGeodesic"));
    circle.setZIndex(((Double) params.get("zIndex")).floatValue());
    circle.setVisible((Boolean) params.get("isVisible"));
    circle.setStrokeColor(((Number) params.get("strokeColor")).intValue());
    circle.setStrokeWidth(((Double) params.get("strokeWidth")).floatValue());
    circle.setFillColor(((Number) params.get("fillColor")).intValue());
  }

  public void remove() {
    if (internallyControlled) {
      return;
    }

    circle.getParent().remove(circle);
  }
}
