package com.unact.yandexmapkit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import android.view.View;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.yandex.mapkit.Animation;
import com.yandex.mapkit.MapKitFactory;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.Polyline;
import com.yandex.mapkit.layers.ObjectEvent;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.PolylineMapObject;
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
  private YandexMapObjectTapListener yandexMapObjectTapListener;
  private UserLocationLayer userLocationLayer;
  private List<PlacemarkMapObject> placemarks = new ArrayList<>();
  private List<PolylineMapObject> polylines = new ArrayList<>();
  private String userLocationIconName;

  public YandexMapController(int id, Context context, PluginRegistry.Registrar registrar) {
    MapKitFactory.initialize(context);
    mapView = new MapView(context);
    MapKitFactory.getInstance().onStart();
    mapView.onStart();
    pluginRegistrar = registrar;
    yandexMapObjectTapListener = new YandexMapObjectTapListener();
    userLocationLayer =
            MapKitFactory.getInstance().createUserLocationLayer(mapView.getMapWindow());
    yandexUserLocationObjectListener = new YandexUserLocationObjectListener(registrar);
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

  @SuppressWarnings("unchecked")
  private void showUserLayer(MethodCall call) {
    if (!hasLocationPermission()) return;

    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    userLocationIconName = (String) params.get("iconName");

    userLocationLayer.setVisible(true);
    userLocationLayer.setHeadingEnabled(true);
    userLocationLayer.setObjectListener(yandexUserLocationObjectListener);
  }

  private void hideUserLayer() {
    if (!hasLocationPermission()) return;

    userLocationLayer.setVisible(false);
  }

  @SuppressWarnings("unchecked")
  private void setMapStyle(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    mapView.getMap().setMapStyle((String) params.get("style"));
  }

  @SuppressWarnings("unchecked")
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

  @SuppressWarnings("unchecked")
  private void setBounds(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    BoundingBox boundingBox = new BoundingBox(
        new Point(((Double) params.get("southWestLatitude")), ((Double) params.get("southWestLongitude"))),
        new Point(((Double) params.get("northEastLatitude")), ((Double) params.get("northEastLongitude")))
    );

    moveWithParams(params, mapView.getMap().cameraPosition(boundingBox));
  }

  @SuppressWarnings("unchecked")
  private void addPlacemark(MethodCall call) {
    addPlacemarkToMap(((Map<String, Object>) call.arguments));
  }

  private Map<String, Object> getTargetPoint() {
    Point point =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("hashCode", point.hashCode());
    arguments.put("latitude", point.getLatitude());
    arguments.put("longitude", point.getLongitude());
    return arguments;
  }

  @SuppressWarnings("unchecked")
  private void removePlacemark(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
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
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PlacemarkMapObject placemark = mapObjects.addPlacemark(point);
    String iconName = (String) params.get("iconName");
    byte[] rawImageData = (byte[]) params.get("rawImageData");

    placemark.setUserData(params.get("hashCode"));
    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDraggable((Boolean) params.get("isDraggable"));
    placemark.addTapListener(yandexMapObjectTapListener);

    if (iconName != null) {
      placemark.setIcon(ImageProvider.fromAsset(mapView.getContext(), pluginRegistrar.lookupKeyForAsset(iconName)));
    }

    if (rawImageData != null) {
      Bitmap bitmapData = BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length);
      placemark.setIcon(ImageProvider.fromBitmap(bitmapData));
    }

    placemarks.add(placemark);
  }

  @SuppressWarnings("unchecked")
  private void addPolyline(MethodCall cell) {
    Map<String, Object> params = (Map<String, Object>)cell.arguments;
    List<Map<String, Object>> coordinates = (List<Map<String, Object>>)params.get("coordinates");
    ArrayList<Point> polylineCoordinates = new ArrayList<>();
    for (Map<String, Object> c: coordinates) {
      Point p = new Point((Double) c.get("latitude"), (Double) c.get("longitude"));
      polylineCoordinates.add(p);
    }
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PolylineMapObject polyline = mapObjects.addPolyline(new Polyline(polylineCoordinates));

    String outlineColorString = String.valueOf(params.get("outlineColor"));
    Long outlineColorLong = Long.parseLong(outlineColorString);

    String strokeColorString = String.valueOf(params.get("strokeColor"));
    Long strokeColorLong = Long.parseLong(strokeColorString);

    polyline.setUserData(params.get("hashCode"));
    polyline.setOutlineColor(outlineColorLong.intValue());
    polyline.setOutlineWidth(((Double)params.get("outlineWidth")).floatValue());
    polyline.setStrokeColor(strokeColorLong.intValue());
    polyline.setStrokeWidth(((Double)params.get("strokeWidth")).floatValue());
    polyline.setGeodesic((boolean)params.get("isGeodesic"));
    polyline.setDashLength(((Double)params.get("dashLength")).floatValue());
    polyline.setDashOffset(((Double)params.get("dashOffset")).floatValue());
    polyline.setGapLength(((Double)params.get("gapLength")).floatValue());

    polylines.add(polyline);
  }

  @SuppressWarnings("unchecked")
  private void removePolyline(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    Iterator<PolylineMapObject> iterator = polylines.iterator();

    while (iterator.hasNext()) {
      PolylineMapObject polylineMapObject = iterator.next();
      if (polylineMapObject.getUserData().equals(params.get("hashCode"))) {
        mapObjects.remove(polylineMapObject);
        iterator.remove();
      }
    }
  }

  private void moveWithParams(Map<String, Object> params, CameraPosition cameraPosition) {
    if (((Boolean) params.get("animate"))) {
      Animation.Type type = ((Boolean) params.get("smoothAnimation")) ? Animation.Type.SMOOTH : Animation.Type.LINEAR;
      Animation animation = new Animation(type, ((Double) params.get("animationDuration")).floatValue());

      mapView.getMap().move(cameraPosition, animation, null);
    } else {
      mapView.getMap().move(cameraPosition);
    }
  }

  private boolean hasLocationPermission() {
    int permissionState = ActivityCompat.checkSelfPermission(mapView.getContext(), Manifest.permission.ACCESS_FINE_LOCATION);
    return permissionState == PackageManager.PERMISSION_GRANTED;
  }

  private void zoomIn() {
    zoom(1f);
  }

  private void zoomOut() {
    zoom(-1f);
  }

  private void zoom(float step) {
    Point zoomPoint = mapView.getMap().getCameraPosition().getTarget();
    float currentZoom = mapView.getMap().getCameraPosition().getZoom();
    float tilt = mapView.getMap().getCameraPosition().getTilt();
    float azimuth = mapView.getMap().getCameraPosition().getAzimuth();
    mapView.getMap().move(
            new CameraPosition(
                zoomPoint,
                currentZoom+step,
                tilt,
                azimuth
            ),
            new Animation(Animation.Type.SMOOTH, 1),
            null);
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
      case "setMapStyle":
        setMapStyle(call);
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
      case "addPolyline":
        addPolyline(call);
        result.success(null);
        break;
      case "removePolyline":
        removePolyline(call);
        result.success(null);
        break;
      case "zoomIn":
        zoomIn();
        result.success(null);
        break;
      case "zoomOut":
        zoomOut();
        result.success(null);
        break;
      case "getTargetPoint":
        Map<String, Object> point = getTargetPoint();
        result.success(point);
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
              pluginRegistrar.lookupKeyForAsset(userLocationIconName)
          )
      );
    }

    public void onObjectRemoved(UserLocationView view) {}

    public void onObjectUpdated(UserLocationView view, ObjectEvent event) {}
  }

  private class YandexMapObjectTapListener implements MapObjectTapListener {
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
