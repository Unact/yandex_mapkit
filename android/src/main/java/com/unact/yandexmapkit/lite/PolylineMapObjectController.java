package com.unact.yandexmapkit.lite;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.LineStyle;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PolylineMapObject;

import java.lang.ref.WeakReference;
import java.util.Map;

public class PolylineMapObjectController extends MapObjectController implements MapObjectTapListener {
  public final PolylineMapObject polyline;
  private boolean consumeTapEvents = false;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"ConstantConditions", "unchecked"})
  public PolylineMapObjectController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    PolylineMapObject polyline = parent.addPolyline(
      UtilsLite.polylineFromJson((Map<String, Object>) params.get("polyline"))
    );

    this.polyline = polyline;
    this.id = (String) params.get("id");
    this.controller = controller;

    polyline.setUserData(this.id);
    polyline.addTapListener(this);
    update(params);
  }

  @SuppressWarnings({"ConstantConditions", "unchecked"})
  public void update(Map<String, Object> params) {
    polyline.setGeometry(UtilsLite.polylineFromJson((Map<String, Object>) params.get("polyline")));
    polyline.setZIndex(((Double) params.get("zIndex")).floatValue());
    polyline.setVisible((Boolean) params.get("isVisible"));
    polyline.setStrokeColor(((Number) params.get("strokeColor")).intValue());
    polyline.setStyle(new LineStyle(
      ((Double) params.get("strokeWidth")).floatValue(),
      ((Double) params.get("gradientLength")).floatValue(),
      ((Number) params.get("outlineColor")).intValue(),
      ((Double) params.get("outlineWidth")).floatValue(),
      (Boolean) params.get("isInnerOutlineEnabled"),
      ((Double) params.get("turnRadius")).floatValue(),
      ((Double) params.get("arcApproximationStep")).floatValue(),
      ((Double) params.get("dashLength")).floatValue(),
      ((Double) params.get("gapLength")).floatValue(),
      ((Double) params.get("dashOffset")).floatValue()
    ));

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
  }

  public void remove() {
    polyline.getParent().remove(polyline);
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectTap(id, point);

    return consumeTapEvents;
  }
}
