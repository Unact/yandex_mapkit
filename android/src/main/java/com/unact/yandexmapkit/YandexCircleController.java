package com.unact.yandexmapkit;

import android.content.Context;

import com.yandex.mapkit.map.CircleMapObject;
import com.yandex.mapkit.map.MapObjectCollection;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexCircleController extends YandexMapObjectController {
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final Context context;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final MethodChannel methodChannel;
  private final CircleMapObject circle;
  private final MapObjectCollection parent;
  public final String id;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public YandexCircleController(
    MapObjectCollection parent,
    Map<String, Object> params,
    MethodChannel methodChannel,
    Context context
  ) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));
    CircleMapObject circle = parent.addCircle(
      Utils.circleFromJson(params),
      ((Number) style.get("strokeColor")).intValue(),
      ((Double) style.get("strokeWidth")).floatValue(),
      ((Number) style.get("fillColor")).intValue()
    );

    this.circle = circle;
    this.id = (String) params.get("id");
    this.parent = parent;
    this.context = context;
    this.methodChannel = methodChannel;

    circle.addTapListener(new YandexMapObjectTapListener(id, methodChannel));
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));

    circle.setStrokeColor(((Number) style.get("strokeColor")).intValue());
    circle.setStrokeWidth(((Double) style.get("strokeWidth")).floatValue());
    circle.setFillColor(((Number) style.get("fillColor")).intValue());
    circle.setGeodesic((boolean) params.get("isGeodesic"));
    circle.setZIndex(((Double) params.get("zIndex")).floatValue());
    circle.setGeometry(Utils.circleFromJson(params));
  }

  public void remove(Map<String, Object> params) {
    parent.remove(circle);
  }
}
