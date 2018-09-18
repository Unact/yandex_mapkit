package com.unact.yandexmapkit;

import android.app.Activity;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.yandex.mapkit.Animation;
import com.yandex.mapkit.MapKitFactory;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectCollectionListener;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.mapview.MapView;
import com.yandex.runtime.image.ImageProvider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class YandexMapkitPlugin implements MethodCallHandler {
  static MethodChannel channel;
  private FrameLayout.LayoutParams currentLayout;
  private Activity activity;
  private MapView mapView;
  private Registrar pluginRegistrar;
  private YandexMapObjectCollectionListener yandexMapObjectCollectionListener;
  private List<PlacemarkMapObject> placemarks = new ArrayList<>();

  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "yandex_mapkit");
    final YandexMapkitPlugin instance = new YandexMapkitPlugin(registrar);

    channel.setMethodCallHandler(instance);
  }

  private YandexMapkitPlugin(Registrar pluginRegistrar) {
    this.pluginRegistrar = pluginRegistrar;
    this.activity = pluginRegistrar.activity();
    this.yandexMapObjectCollectionListener = new YandexMapObjectCollectionListener();
  }

  private void setApiKey(MethodCall call) {
    MapKitFactory.setApiKey(call.arguments.toString());
    MapKitFactory.initialize(this.activity);
  }

  private void hide(MethodCall call) {
    if (this.mapView == null) return;

    stopView();
  }

  private void move(MethodCall call) {
    if (this.mapView == null) return;

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

  private void resize(MethodCall call) {
    if (this.mapView == null) return;

    stopView();
    this.currentLayout = parseRect(((Map<String, Double>) call.arguments));
    startView();
  }

  private void reset(MethodCall call) {
    hide(call);
    removePlacemarks(call);
    destroy(call);
    create(call);
  }

  private void show(MethodCall call) {
    if (this.mapView == null) return;

    startView();
  }

  private void showResize(MethodCall call) {
    if (this.mapView == null) return;

    resize(call);
    show(call);
  }

  private void setBounds(MethodCall call) {
    if (this.mapView == null) return;

    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) params.get("southWestLatitude")), ((Double) params.get("southWestLongitude"))),
      new Point(((Double) params.get("northEastLatitude")), ((Double) params.get("northEastLongitude")))
    );

    moveWithParams(params, mapView.getMap().cameraPosition(boundingBox));
  }

  private void addPlacemark(MethodCall call) {
    if (this.mapView == null) return;

    addPlacemarkToMap(((Map<String, Object>) call.arguments));
  }

  private void addPlacemarks(MethodCall call) {
    if (this.mapView == null) return;

    List<Map<String, Object>> placemarkParams = ((List<Map<String, Object>>) call.arguments);
    Iterator<Map<String, Object>> iterator = placemarkParams.iterator();

    while (iterator.hasNext()) {
      addPlacemarkToMap(iterator.next());
    }
  }

  private void removePlacemark(MethodCall call) {
    if (this.mapView == null) return;

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

  private void removePlacemarks(MethodCall call) {
    if (this.mapView == null) return;

    this.mapView.getMap().getMapObjects().clear();
    this.placemarks.clear();
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
      placemark.setIcon(ImageProvider.fromAsset(this.activity, this.pluginRegistrar.lookupKeyForAsset(iconName)));
    }

    placemarks.add(placemark);
  }

  private void create(MethodCall call) {
    if (this.mapView != null) return;

    this.mapView = new MapView(this.activity);
    this.currentLayout = zeroRect();
    this.mapView.getMap().getMapObjects().addListener(this.yandexMapObjectCollectionListener);
    startView();
  }

  private void destroy(MethodCall call) {
    if (this.mapView == null) return;

    stopView();
    this.mapView = null;
    this.currentLayout = null;
  }

  private void moveWithParams(Map<String, Object> params, CameraPosition cameraPosition) {
    if (isMapViewEmptyRect()) return;

    if (((Boolean) params.get("animate"))) {
      Animation.Type type = ((Boolean) params.get("smoothAnimation")) ? Animation.Type.SMOOTH : Animation.Type.LINEAR;
      Animation animation = new Animation(type, ((Double) params.get("animationDuration")).floatValue());

      this.mapView.getMap().move(cameraPosition, animation, null);
    } else {
      this.mapView.getMap().move(cameraPosition);
    }
  }

  private FrameLayout.LayoutParams parseRect(Map<String, Double> rect) {
    FrameLayout.LayoutParams newRect = new FrameLayout.LayoutParams(
      dp2px(this.activity, rect.get("width").floatValue()),
      dp2px(this.activity, rect.get("height").floatValue())
    );
    newRect.setMargins(
      dp2px(this.activity, rect.get("left").floatValue()),
      dp2px(this.activity, rect.get("top").floatValue()),
      0,
      0
    );

    return newRect;
  }

  private FrameLayout.LayoutParams zeroRect() {
    Map<String, Double> rectParams = new HashMap<>();
    rectParams.put("width", ((double) 0));
    rectParams.put("height", ((double) 0));
    rectParams.put("left", ((double) 0));
    rectParams.put("top", ((double) 0));

    return parseRect(rectParams);
  }

  private boolean isMapViewEmptyRect() {
    if (this.mapView == null) return true;

    FrameLayout.LayoutParams layout = (FrameLayout.LayoutParams) mapView.getLayoutParams();
    FrameLayout.LayoutParams zeroLayout = zeroRect();

    if (
      layout.width == zeroLayout.width &&
      layout.height == zeroLayout.height &&
      layout.leftMargin == zeroLayout.leftMargin &&
      layout.topMargin == zeroLayout.topMargin
    ) {
      return true;
    } else {
      return false;
    }
  }

  private void startView() {
    ViewGroup viewGroup = ((ViewGroup) (this.mapView.getParent()));

    if (viewGroup == null) {
      this.activity.addContentView(this.mapView, this.currentLayout);
      MapKitFactory.getInstance().onStart();
      this.mapView.onStart();
    }
  }

  private void stopView() {
    ViewGroup viewGroup = ((ViewGroup) (this.mapView.getParent()));

    if (viewGroup != null) {
      viewGroup.removeView(this.mapView);
      this.mapView.onStop();
      MapKitFactory.getInstance().onStop();
    }
  }

  private int dp2px(Activity context, float dp) {
    final float scale = context.getResources().getDisplayMetrics().density;
    return (int) (dp * scale + 0.5f);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "setApiKey":
        setApiKey(call);
        result.success(null);
        break;
      case "hide":
        hide(call);
        result.success(null);
        break;
      case "move":
        move(call);
        result.success(null);
        break;
      case "resize":
        resize(call);
        result.success(null);
        break;
      case "reset":
        reset(call);
        result.success(null);
        break;
      case "show":
        show(call);
        result.success(null);
        break;
      case "showResize":
        showResize(call);
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
      case "addPlacemarks":
        addPlacemarks(call);
        result.success(null);
        break;
      case "removePlacemark":
        removePlacemark(call);
        result.success(null);
        break;
      case "removePlacemarks":
        removePlacemarks(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
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

        channel.invokeMethod("onMapObjectTap", arguments);

        return true;
      }
    }
  }
}
