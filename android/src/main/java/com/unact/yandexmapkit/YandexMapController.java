package com.unact.yandexmapkit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.view.View;

import com.yandex.mapkit.Animation;
import com.yandex.mapkit.MapKitFactory;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.layers.ObjectEvent;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectCollectionListener;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.mapview.MapView;
import com.yandex.mapkit.user_location.UserLocationLayer;
import com.yandex.mapkit.user_location.UserLocationObjectListener;
import com.yandex.mapkit.user_location.UserLocationView;
import com.yandex.runtime.image.ImageProvider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;


public class YandexMapController implements PlatformView, MethodChannel.MethodCallHandler {
  private final MapView mapView;
  private final MethodChannel methodChannel;
  private final PluginRegistry.Registrar pluginRegistrar;
  private YandexUserLocationObjectListener yandexUserLocationObjectListener;
  private YandexMapObjectCollectionListener yandexMapObjectCollectionListener;
  private List<PlacemarkMapObject> placemarks = new ArrayList<>();
  private String userLocationIconName;

  public YandexMapController(int id, Context context, PluginRegistry.Registrar registrar) {
    MapKitFactory.initialize(context);
    mapView = new MapView(context);
    MapKitFactory.getInstance().onStart();
    mapView.onStart();
    pluginRegistrar = registrar;
    this.yandexMapObjectCollectionListener = new YandexMapObjectCollectionListener();
    this.yandexUserLocationObjectListener = new YandexUserLocationObjectListener(registrar);
    this.mapView.getMap().getMapObjects().addListener(this.yandexMapObjectCollectionListener);
    methodChannel = new MethodChannel(registrar.messenger(), "yandex_mapkit/yandex_map_" + id);
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public View getView() {
    return mapView;
  }

  @Override
  public void dispose() {
    mapView.onStop();
    MapKitFactory.getInstance().onStop();
  }


  private void showUserLayer(MethodCall call) {
    if (!hasLocationPermission()) return;

    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    userLocationIconName = (String) params.get("iconName");

    UserLocationLayer userLocationLayer = this.mapView.getMap().getUserLocationLayer();
    userLocationLayer.setEnabled(true);
    userLocationLayer.setHeadingEnabled(true);
    userLocationLayer.setObjectListener(this.yandexUserLocationObjectListener);
  }

  private void hideUserLayer() {
    if (!hasLocationPermission()) return;

    UserLocationLayer userLocationLayer = this.mapView.getMap().getUserLocationLayer();
    userLocationLayer.setEnabled(false);
  }

  private void move(MethodCall call) {
        Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Point point = new Point(((Double) params.get("latitude")), ((Double) params.get("longitude")));
    CameraPosition cameraPosition = new CameraPosition(
        point,
        ((Double) params.get("zoom")).floatValue(),
        ((Double) params.get("azimuth")).floatValue(),
        ((Double) params.get("tilt")).floatValue()
    );

    moveWithParams(params, cameraPosition);
  }

  private void setBounds(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    BoundingBox boundingBox = new BoundingBox(
        new Point(((Double) params.get("southWestLatitude")), ((Double) params.get("southWestLongitude"))),
        new Point(((Double) params.get("northEastLatitude")), ((Double) params.get("northEastLongitude")))
    );

    moveWithParams(params, mapView.getMap().cameraPosition(boundingBox));
  }

  private void addPlacemark(MethodCall call) {
    addPlacemarkToMap(((Map<String, Object>) call.arguments));
  }

  private void removePlacemark(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = this.mapView.getMap().getMapObjects();
    Iterator<PlacemarkMapObject> iterator = placemarks.iterator();

    while (iterator.hasNext()) {
      PlacemarkMapObject placemarkMapObject = iterator.next();
      if (placemarkMapObject.getUserData().equals(params.get("hashCode"))) {
        mapObjects.remove(placemarkMapObject);
        iterator.remove();
      }
    }
  }

  private void addPlacemarkToMap(Map<String, Object> params) {
    Point point = new Point(((Double) params.get("latitude")), ((Double) params.get("longitude")));
    MapObjectCollection mapObjects = this.mapView.getMap().getMapObjects();
    PlacemarkMapObject placemark = mapObjects.addPlacemark(point);
    String iconName = (String) params.get("iconName");

    placemark.setUserData(params.get("hashCode"));
    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDraggable((Boolean) params.get("isDraggable"));

    if (iconName != null) {
      placemark.setIcon(ImageProvider.fromAsset(this.mapView.getContext(), pluginRegistrar.lookupKeyForAsset(iconName)));
    }

    placemarks.add(placemark);
  }


  private void moveWithParams(Map<String, Object> params, CameraPosition cameraPosition) {
    if (((Boolean) params.get("animate"))) {
      Animation.Type type = ((Boolean) params.get("smoothAnimation")) ? Animation.Type.SMOOTH : Animation.Type.LINEAR;
      Animation animation = new Animation(type, ((Double) params.get("animationDuration")).floatValue());

      this.mapView.getMap().move(cameraPosition, animation, null);
    } else {
      this.mapView.getMap().move(cameraPosition);
    }
  }


  private boolean hasLocationPermission() {
    int permissionState = ActivityCompat.checkSelfPermission(this.mapView.getContext(), Manifest.permission.ACCESS_FINE_LOCATION);
    return permissionState == PackageManager.PERMISSION_GRANTED;
  }


  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "showUserLayer":
        showUserLayer(call);
        result.success(null);
        break;
      case "hideUserLayer":
        hideUserLayer();
        result.success(null);
        break;
      case "move":
        move(call);
        result.success(null);
        break;
      case "setBounds":
        setBounds(call);
        result.success(null);
        break;
      case "addPlacemark":
        addPlacemark(call);
        result.success(null);
        break;
      case "removePlacemark":
        removePlacemark(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private class YandexUserLocationObjectListener implements UserLocationObjectListener {
    private PluginRegistry.Registrar pluginRegistrar;

    private YandexUserLocationObjectListener(PluginRegistry.Registrar pluginRegistrar) {
      this.pluginRegistrar = pluginRegistrar;
    }

    public void onObjectAdded(UserLocationView view) {
      view.getPin().setIcon(
          ImageProvider.fromAsset(
              pluginRegistrar.activity(),
              this.pluginRegistrar.lookupKeyForAsset(userLocationIconName)
          )
      );
    }

    public void onObjectRemoved(UserLocationView view) {}

    public void onObjectUpdated(UserLocationView view, ObjectEvent event) {}
  }

  private class YandexMapObjectCollectionListener implements MapObjectCollectionListener {
    private YandexMapObjectTapListener yandexMapObjectTapListener;

    private YandexMapObjectCollectionListener() {
      this.yandexMapObjectTapListener = new YandexMapObjectTapListener();
    }

    public void onMapObjectAdded(MapObject mapObject) {
      mapObject.addTapListener(this.yandexMapObjectTapListener);
    }

    public void onMapObjectRemoved(MapObject mapObject) {
      mapObject.removeTapListener(this.yandexMapObjectTapListener);
    }

    public void onMapObjectUpdated(MapObject mapObject) {}

    class YandexMapObjectTapListener implements MapObjectTapListener {
      public boolean onMapObjectTap(MapObject mapObject, Point point) {
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("hashCode", mapObject.getUserData());
        arguments.put("latitude", point.getLatitude());
        arguments.put("longitude", point.getLongitude());

        methodChannel.invokeMethod("onMapObjectTap", arguments);

        return true;
      }
    }
  }
}
