package com.unact.yandexmapkit;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.BaseMapObjectCollection;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
import com.yandex.mapkit.map.CompositeIcon;
import com.yandex.mapkit.map.IconStyle;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectDragListener;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.RotationType;
import com.yandex.mapkit.map.TextStyle;
import com.yandex.runtime.image.ImageProvider;

import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.util.List;
import java.util.Map;

import io.flutter.FlutterInjector;

public class PlacemarkMapObjectController
  extends MapObjectController
  implements MapObjectTapListener, MapObjectDragListener
{
  private final boolean internallyControlled;
  public final PlacemarkMapObject placemark;
  private boolean consumeTapEvents = false;
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public PlacemarkMapObjectController(
    BaseMapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    PlacemarkMapObject placemark = null;
    Point point = Utils.pointFromJson((Map<String, Object>) params.get("point"));

    if (parent instanceof ClusterizedPlacemarkCollection) {
      placemark = ((ClusterizedPlacemarkCollection) parent).addPlacemark();
    }

    if (parent instanceof MapObjectCollection) {
       placemark = ((MapObjectCollection) parent).addPlacemark();
    }

    this.placemark = placemark;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.internallyControlled = false;

    placemark.setUserData(id);
    placemark.addTapListener(this);
    placemark.setDragListener(this);
    update(params);
  }

  public PlacemarkMapObjectController(
    PlacemarkMapObject placemark,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
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
      placemark.setVisible((Boolean) params.get("isVisible"));
    }

    placemark.setZIndex(((Double) params.get("zIndex")).floatValue());
    placemark.setDraggable((Boolean) params.get("isDraggable"));
    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDirection(((Double) params.get("direction")).floatValue());

    setText(((Map<String, Object>) params.get("text")));
    setIcon(((Map<String, Object>) params.get("icon")));

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
  }

  public void remove() {
    if (internallyControlled) {
      return;
    }

    placemark.getParent().remove(placemark);
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

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void setText(Map<String, Object> text) {
    if (text == null) {
      return;
    }

    placemark.setText((String) text.get("text"), getTextStyle(((Map<String, Object>) text.get("style"))));
  }

  @SuppressWarnings({"ConstantConditions"})
  private ImageProvider getIconImage(Map<String, Object> image) {
    String type = (String) image.get("type");
    ImageProvider defaultImage = ImageProvider.fromBitmap(Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888));

    if (type.equals("fromAssetImage")) {
      String assetName = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset((String) image.get("assetName"));

      try (InputStream i = controller.get().context.getAssets().open(assetName)) {
        Bitmap result = BitmapFactory.decodeStream(i);

        return ImageProvider.fromBitmap(result);
      } catch (java.io.IOException e) {
        return defaultImage;
      }
    }

    if (type.equals("fromBytes")) {
      byte[] rawImageData = (byte[]) image.get("rawImageData");
      Bitmap bitmap = BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length);

      if (bitmap != null) {
        return ImageProvider.fromBitmap(bitmap);
      }

      return defaultImage;
    }

    return defaultImage;
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

  @SuppressWarnings({"ConstantConditions"})
  private TextStyle getTextStyle(Map<String, Object> style) {
    TextStyle textStyle = new TextStyle();

    if (style.get("color") != null) {
      textStyle.setColor(((Number) style.get("color")).intValue());
    }

    if (style.get("outlineColor") != null) {
      textStyle.setOutlineColor(((Number) style.get("outlineColor")).intValue());
    }

    textStyle.setSize(((Double) style.get("size")).floatValue());
    textStyle.setOffset(((Double) style.get("offset")).floatValue());
    textStyle.setOffsetFromIcon((Boolean) style.get("offsetFromIcon"));
    textStyle.setTextOptional((Boolean) style.get("textOptional"));
    textStyle.setPlacement(TextStyle.Placement.values()[(Integer) style.get("placement")]);

    return textStyle;
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
