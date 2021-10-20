package com.unact.yandexmapkit;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PointF;

import com.yandex.mapkit.map.IconStyle;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.RotationType;
import com.yandex.runtime.image.ImageProvider;

import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.plugin.common.MethodChannel;

public class YandexPlacemarkController extends YandexMapObjectController {
  private final Context context;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final MethodChannel methodChannel;
  private final PlacemarkMapObject placemark;
  private final MapObjectCollection parent;
  public final String id;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public YandexPlacemarkController(
    MapObjectCollection parent,
    Map<String, Object> params,
    MethodChannel methodChannel,
    Context context
  ) {
    PlacemarkMapObject placemark = parent.addPlacemark(Utils.pointFromJson((Map<String, Object>) params.get("point")));

    this.placemark = placemark;
    this.id = (String) params.get("id");
    this.parent = parent;
    this.context = context;
    this.methodChannel = methodChannel;

    placemark.addTapListener(new YandexMapObjectTapListener(id, methodChannel));
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    Map<String, Object> style = ((Map<String, Object>) params.get("style"));

    String iconName = (String) style.get("iconName");
    Map<String, Object> iconAnchor = (Map<String, Object>) style.get("iconAnchor");
    byte[] rawImageData = (byte[]) style.get("rawImageData");

    placemark.setOpacity(((Double) style.get("opacity")).floatValue());
    placemark.setDirection(((Double) style.get("direction")).floatValue());

    if (iconName != null) {
      placemark.setIcon(ImageProvider.fromAsset(
        context,
        FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(iconName)
      ));
    }

    if (rawImageData != null) {
      Bitmap bitmapData = BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length);
      placemark.setIcon(ImageProvider.fromBitmap(bitmapData));
    }

    IconStyle iconStyle = new IconStyle();
    iconStyle.setAnchor(
      new PointF(
        ((Double) iconAnchor.get("dx")).floatValue(),
        ((Double) iconAnchor.get("dy")).floatValue()
      )
    );
    iconStyle.setScale(((Double) style.get("scale")).floatValue());

    int rotationType = ((Number) style.get("rotationType")).intValue();
    if (rotationType == RotationType.ROTATE.ordinal()) {
      iconStyle.setRotationType(RotationType.ROTATE);
    }

    placemark.setIconStyle(iconStyle);
    placemark.setDraggable((Boolean) params.get("isDraggable"));
    placemark.setZIndex(((Double) params.get("zIndex")).floatValue());
    placemark.setGeometry(Utils.pointFromJson((Map<String, Object>) params.get("point")));
  }

  public void remove(Map<String, Object> params) {
    parent.remove(placemark);
  }
}
