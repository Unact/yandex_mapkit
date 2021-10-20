package com.unact.yandexmapkit;

import android.content.Context;

import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PolylineMapObject;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexPolylineController extends YandexMapObjectController {
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final Context context;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final MethodChannel methodChannel;
  private final PolylineMapObject polyline;
  private final MapObjectCollection parent;
  public final String id;

  public YandexPolylineController(
    MapObjectCollection parent,
    Map<String, Object> params,
    MethodChannel methodChannel,
    Context context
  ) {
    PolylineMapObject polyline = parent.addPolyline(Utils.polylineFromJson(params));

    this.polyline = polyline;
    this.id = (String) params.get("id");
    this.parent = parent;
    this.context = context;
    this.methodChannel = methodChannel;

    polyline.addTapListener(new YandexMapObjectTapListener(id, methodChannel));
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

  public void remove(Map<String, Object> params) {
    parent.remove(polyline);
  }
}
