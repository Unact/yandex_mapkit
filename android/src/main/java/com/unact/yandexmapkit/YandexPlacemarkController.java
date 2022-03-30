package com.unact.yandexmapkit;

import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
import com.yandex.mapkit.map.CompositeIcon;
import com.yandex.mapkit.map.IconStyle;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectDragListener;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.RotationType;
import com.yandex.runtime.image.ImageProvider;

import java.lang.ref.WeakReference;
import java.util.List;
import java.util.Map;

import io.flutter.FlutterInjector;

public class YandexPlacemarkController
  extends YandexMapObjectController
  implements MapObjectTapListener, MapObjectDragListener
{
  private final boolean internallyControlled;
  private final MapObject parent; // Workaround https://github.com/yandex/mapkit-android-demo/issues/258
  public final PlacemarkMapObject placemark;
  private boolean consumeTapEvents = false;
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
    this.internallyControlled = false;

    placemark.setUserData(id);
    placemark.addTapListener(this);
    placemark.setDragListener(this);
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
    this.internallyControlled = true;

    placemark.setUserData(id);
    placemark.addTapListener(this);
    placemark.setDragListener(this);
    update(params);
  }
  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    if (!internallyControlled) {
      placemark.setGeometry(Utils.pointFromJson((Map<String, Object>) params.get("point")));
    }

    placemark.setZIndex(((Double) params.get("zIndex")).floatValue());
    placemark.setVisible((Boolean) params.get("isVisible"));
    placemark.setDraggable((Boolean) params.get("isDraggable"));
    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDirection(((Double) params.get("direction")).floatValue());

    setIcon(((Map<String, Object>) params.get("icon")));

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
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

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void setIcon(Map<String, Object> icon) {
    if (icon == null) {
      return;
    }

    String iconType = ((String) icon.get("type"));

    if (iconType.equals("single")) {
      Map<String, Object> style = ((Map<String, Object>) icon.get("style"));
      Map<String, Object> image = ((Map<String, Object>) style.get("image"));

      placemark.setIcon(getIconImage(image), getIconStyle(style));
    }

    if (iconType.equals("composite")) {
      CompositeIcon compositeIcon = placemark.useCompositeIcon();
      List<Map<String, Object>> iconParts = ((List<Map<String, Object>>) icon.get("iconParts"));

      for (Map<String, Object> iconPart: iconParts) {
        Map<String, Object> style = ((Map<String, Object>) iconPart.get("style"));
        Map<String, Object> image = ((Map<String, Object>) style.get("image"));
        String name = (String) iconPart.get("name");

        compositeIcon.setIcon(name, getIconImage(image), getIconStyle(style));
      }
    }
  }

  @SuppressWarnings({"ConstantConditions"})
  private ImageProvider getIconImage(Map<String, Object> image) {
    String type = (String) image.get("type");

    if (type.equals("fromAssetImage")) {
      return ImageProvider.fromAsset(
        controller.get().context,
        FlutterInjector.instance().flutterLoader().getLookupKeyForAsset((String) image.get("assetName"))
      );
    }
    
    if (type.equals("fromBytes")) {
      byte[] rawImageData = (byte[]) image.get("rawImageData");

      return ImageProvider.fromBitmap(BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length));
    }

    return null;
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private IconStyle getIconStyle(Map<String, Object> style) {
    IconStyle iconStyle = new IconStyle();

    if (style.get("tappableArea") != null) {
      iconStyle.setTappableArea(Utils.rectFromJson((Map<String, Object>) style.get("tappableArea")));
    }

    iconStyle.setAnchor(Utils.rectPointFromJson((Map<String, Double>) style.get("anchor")));
    iconStyle.setZIndex(((Double) style.get("zIndex")).floatValue());
    iconStyle.setScale(((Double) style.get("scale")).floatValue());
    iconStyle.setVisible((Boolean) style.get("isVisible"));
    iconStyle.setFlat((Boolean) style.get("isFlat"));
    iconStyle.setRotationType(RotationType.values()[(Integer) style.get("rotationType")]);
    
    return iconStyle;
  }

  @Override
  public void onMapObjectDragStart(@NonNull MapObject mapObject) {
    controller.get().mapObjectDragStart(id);
  }

  @Override
  public void onMapObjectDrag(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectDrag(id, point);
  }

  @Override
  public void onMapObjectDragEnd(@NonNull MapObject mapObject) {
    controller.get().mapObjectDragEnd(id);
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectTap(id, point);

    return consumeTapEvents;
  }
}
