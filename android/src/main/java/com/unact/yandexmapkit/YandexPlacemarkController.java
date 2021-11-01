package com.unact.yandexmapkit;

import android.graphics.BitmapFactory;
import android.graphics.PointF;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
import com.yandex.mapkit.map.IconStyle;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.RotationType;
import com.yandex.runtime.image.ImageProvider;

import java.lang.ref.WeakReference;
import java.util.Map;

import io.flutter.FlutterInjector;

public class YandexPlacemarkController extends YandexMapObjectController {
  private final boolean internallyControlled;
  private final MapObject parent; // Workaround https://github.com/yandex/mapkit-android-demo/issues/258
  public final PlacemarkMapObject placemark;
  private final YandexMapObjectTapListener tapListener;
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public YandexPlacemarkController(
    MapObject parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    PlacemarkMapObject placemark = null;
    Point point = Utils.pointFromJson((Map<String, Object>) params.get("point"));

    if (parent instanceof ClusterizedPlacemarkCollection) {
      placemark = ((ClusterizedPlacemarkCollection) parent).addPlacemark(point);
    }

    if (parent instanceof MapObjectCollection) {
       placemark = ((MapObjectCollection) parent).addPlacemark(point);
    }

    this.parent = parent;
    this.placemark = placemark;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);
    this.internallyControlled = false;

    placemark.setUserData(id);
    placemark.addTapListener(tapListener);
    update(params);
  }

  public YandexPlacemarkController(
    MapObject parent,
    PlacemarkMapObject placemark,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    this.parent = parent;
    this.placemark = placemark;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);
    this.internallyControlled = true;

    placemark.setUserData(id);
    placemark.addTapListener(tapListener);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));

    String iconName = (String) style.get("iconName");
    Map<String, Object> iconAnchor = (Map<String, Object>) style.get("iconAnchor");
    byte[] rawImageData = (byte[]) style.get("rawImageData");
    ImageProvider image = null;

    placemark.setOpacity(((Double) style.get("opacity")).floatValue());
    placemark.setDirection(((Double) style.get("direction")).floatValue());

    if (iconName != null) {
      image = ImageProvider.fromAsset(
        controller.get().context,
        FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(iconName)
      );
    }

    if (rawImageData != null) {
      image = ImageProvider.fromBitmap(BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length));
    }

    if (image != null) {
      IconStyle iconStyle = new IconStyle();
      int rotationType = ((Number) style.get("rotationType")).intValue();
      if (rotationType == RotationType.ROTATE.ordinal()) {
        iconStyle.setRotationType(RotationType.ROTATE);
      }

      iconStyle.setAnchor(new PointF(((Double) iconAnchor.get("dx")).floatValue(), ((Double) iconAnchor.get("dy")).floatValue()));
      iconStyle.setScale(((Double) style.get("scale")).floatValue());
      placemark.setIcon(image);
      placemark.setIconStyle(iconStyle);
    }

    placemark.setDraggable((Boolean) params.get("isDraggable"));
    placemark.setZIndex(((Double) params.get("zIndex")).floatValue());
    placemark.setGeometry(Utils.pointFromJson((Map<String, Object>) params.get("point")));
  }

  public void remove() {
    if (internallyControlled) {
      return;
    }

    if (parent instanceof ClusterizedPlacemarkCollection) {
      ((ClusterizedPlacemarkCollection) parent).remove(placemark);
    }

    if (parent instanceof MapObjectCollection) {
      ((MapObjectCollection) parent).remove(placemark);
    }
  }
}
