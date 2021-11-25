package com.unact.yandexmapkit;

import android.graphics.BitmapFactory;
import android.graphics.PointF;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
import com.yandex.mapkit.map.IconStyle;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.Rect;
import com.yandex.mapkit.map.RotationType;
import com.yandex.runtime.image.ImageProvider;

import java.lang.ref.WeakReference;
import java.util.List;
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
  
    applyPlacemarkStyle(placemark, style);
    placemark.setZIndex(((Double) params.get("zIndex")).floatValue());
    placemark.setGeometry(Utils.pointFromJson((Map<String, Object>) params.get("point")));
    placemark.setVisible((Boolean) params.get("isVisible"));
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
  
  private void applyPlacemarkStyle(PlacemarkMapObject placemark, Map<String, Object> params) {
    
    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDirection(((Double) params.get("direction")).floatValue());
    
    Map<String, Object> icon = ((Map<String, Object>) params.get("icon"));
    List<Map<String, Object>> composite = (List<Map<String, Object>>) params.get("composite");
    
    if (icon != null) {
      
      ImageProvider img = getIconImage(icon);
      
      if (img != null) {
        placemark.setIcon(img);
      }
      
      Map<String, Object> iconStyle = ((Map<String, Object>) icon.get("style"));
      IconStyle style = getIconStyle(iconStyle);
      placemark.setIconStyle(style);
      
    } else if (composite != null) {
      
      for (Map<String, Object> iconData: composite) {
        
        ImageProvider img = getIconImage(iconData);
        
        Map<String, Object> iconStyle = ((Map<String, Object>) iconData.get("style"));
        IconStyle style = getIconStyle(iconStyle);
        
        placemark.useCompositeIcon().setIcon((String) iconData.get("layerName"), img, style);
      }
    }
  }
  
  private ImageProvider getIconImage(Map<String, Object> iconData) {
    
    ImageProvider img;
    
    String iconName = (String) iconData.get("iconName");
    byte[] rawImageData = (byte[]) iconData.get("rawImageData");
    
    if (iconName != null) {
      img = ImageProvider.fromAsset(
        controller.get().context,
        FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(iconName)
      );
    } else {
      img = ImageProvider.fromBitmap(BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length));
    }
    
    return img;
  }
  
  private IconStyle getIconStyle(Map<String, Object> styleParams) {
    
    IconStyle iconStyle = new IconStyle();
    
    int rotationType = ((Number) styleParams.get("rotationType")).intValue();
    if (rotationType == RotationType.ROTATE.ordinal()) {
      iconStyle.setRotationType(RotationType.ROTATE);
    }
    
    Map<String, Object> anchor = ((Map<String, Object>) styleParams.get("anchor"));
    
    iconStyle.setAnchor(
      new PointF(
        ((Double) anchor.get("dx")).floatValue(),
        ((Double) anchor.get("dy")).floatValue()
      )
    );
    
    iconStyle.setZIndex(((Double) styleParams.get("zIndex")).floatValue());
    iconStyle.setScale(((Double) styleParams.get("scale")).floatValue());
    
    Map<String, Object> tappableArea = ((Map<String, Object>) styleParams.get("tappableArea"));
    
    if (tappableArea != null) {
      
      Map<String, Object> tappableAreaMin = ((Map<String, Object>) tappableArea.get("min"));
      Map<String, Object> tappableAreaMax = ((Map<String, Object>) tappableArea.get("max"));
      
      iconStyle.setTappableArea(
        new Rect(
          new PointF(
            ((Double) tappableAreaMin.get("x")).floatValue(),
            ((Double) tappableAreaMin.get("y")).floatValue()
          ),
          new PointF(
            ((Double) tappableAreaMax.get("x")).floatValue(),
            ((Double) tappableAreaMax.get("y")).floatValue()
          )
        )
      );
    }

    iconStyle.setVisible((Boolean) styleParams.get("isVisible"));
    
    return iconStyle;
  }
}
