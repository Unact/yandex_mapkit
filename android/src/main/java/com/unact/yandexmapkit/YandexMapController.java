package com.unact.yandexmapkit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.view.View;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PointF;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.yandex.mapkit.Animation;
import com.yandex.mapkit.MapKitFactory;
import com.yandex.mapkit.ScreenPoint;
import com.yandex.mapkit.ScreenRect;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Circle;
import com.yandex.mapkit.geometry.LinearRing;
import com.yandex.mapkit.geometry.Polygon;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.Polyline;
import com.yandex.mapkit.layers.ObjectEvent;
import com.yandex.mapkit.logo.Alignment;
import com.yandex.mapkit.logo.HorizontalAlignment;
import com.yandex.mapkit.logo.VerticalAlignment;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.CircleMapObject;
import com.yandex.mapkit.map.InputListener;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;
import com.yandex.mapkit.map.PointOfView;
import com.yandex.mapkit.map.PolylineMapObject;
import com.yandex.mapkit.map.PolygonMapObject;
import com.yandex.mapkit.map.IconStyle;
import com.yandex.mapkit.map.CameraUpdateReason;
import com.yandex.mapkit.map.CameraListener;
import com.yandex.mapkit.map.Rect;
import com.yandex.mapkit.map.RotationType;
import com.yandex.mapkit.map.VisibleRegion;
import com.yandex.mapkit.map.SizeChangedListener;
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

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.view.FlutterMain;

public class YandexMapController implements PlatformView, MethodChannel.MethodCallHandler, DefaultLifecycleObserver {
  private final MapView mapView;
  private final MethodChannel methodChannel;
  private final YandexMapkitPlugin.LifecycleProvider lifecycleProvider;
  private YandexUserLocationObjectListener yandexUserLocationObjectListener;
  private YandexCameraListener yandexCameraListener;
  private YandexMapObjectTapListener yandexMapObjectTapListener;
  private YandexMapInputListener yandexMapInputListener;
  private YandexMapSizeChangedListener yandexMapSizeChangedListener;
  private UserLocationLayer userLocationLayer;
  private PlacemarkMapObject cameraTarget = null;
  private List<PlacemarkMapObject> placemarks = new ArrayList<>();
  private List<PolylineMapObject> polylines = new ArrayList<>();
  private List<PolygonMapObject> polygons = new ArrayList<>();
  private List<CircleMapObject> circles = new ArrayList<>();
  private String userLocationIconName;
  private String userArrowIconName;
  private Boolean userArrowOrientation;
  private int accuracyCircleFillColor = 0;
  private boolean disposed = false;

  public YandexMapController(int id, Context context, BinaryMessenger messenger, YandexMapkitPlugin.LifecycleProvider lifecycleProvider) {
    this.lifecycleProvider = lifecycleProvider;
    mapView = new MapView(context);
    mapView.onStart();

    yandexMapObjectTapListener = new YandexMapObjectTapListener();
    yandexMapInputListener = new YandexMapInputListener();
    yandexMapSizeChangedListener = new YandexMapSizeChangedListener();
    userLocationLayer = MapKitFactory.getInstance().createUserLocationLayer(mapView.getMapWindow());
    yandexUserLocationObjectListener = new YandexUserLocationObjectListener();

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_map_" + id);
    methodChannel.setMethodCallHandler(this);

    mapView.getMap().addInputListener(yandexMapInputListener);
    mapView.getMapWindow().addSizeChangedListener(yandexMapSizeChangedListener);

    lifecycleProvider.getLifecycle().addObserver(this);
  }

  @Override
  public View getView() {
    return mapView;
  }

  @Override
  public void dispose() {
    if (disposed) {
      return;
    }

    disposed = true;
    methodChannel.setMethodCallHandler(null);

    Lifecycle lifecycle = lifecycleProvider.getLifecycle();
    if (lifecycle != null) {
      lifecycle.removeObserver(this);
    }
  }

  @SuppressWarnings("unchecked")
  public void toggleNightMode(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMap().setNightModeEnabled((Boolean) params.get("enabled"));
  }

  @SuppressWarnings("unchecked")
  public void toggleMapRotation(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMap().setRotateGesturesEnabled((Boolean) params.get("enabled"));
  }

  @SuppressWarnings("unchecked")
  public void setFocusRect(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsTopLeft = ((Map<String, Object>) params.get("topLeft"));
    Map<String, Object> paramsBottomRight = ((Map<String, Object>) params.get("bottomRight"));
    ScreenRect screenRect = new ScreenRect(
      new ScreenPoint(
        ((Double) paramsTopLeft.get("x")).floatValue(),
        ((Double) paramsTopLeft.get("y")).floatValue()
      ),
      new ScreenPoint(
        ((Double) paramsBottomRight.get("x")).floatValue(),
        ((Double) paramsBottomRight.get("y")).floatValue()
      )
    );

    mapView.setFocusRect(screenRect);
    mapView.setPointOfView(PointOfView.ADAPT_TO_FOCUS_RECT_HORIZONTALLY);
  }

  public void clearFocusRect() {
    mapView.setFocusRect(null);
    mapView.setPointOfView(PointOfView.SCREEN_CENTER);
  }

  @SuppressWarnings("unchecked")
  public void logoAlignment(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Alignment logoPosition = new Alignment(
      HorizontalAlignment.values()[(Integer) params.get("horizontal")],
      VerticalAlignment.values()[(Integer) params.get("vertical")]
    );
    mapView.getMap().getLogo().setAlignment(logoPosition);
  }

  @SuppressWarnings("unchecked")
  public void showUserLayer(MethodCall call) {

    if (!hasLocationPermission()) return;

    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    userLocationIconName = (String) params.get("iconName");
    userArrowIconName = (String) params.get("arrowName");
    userArrowOrientation = (Boolean) params.get("userArrowOrientation");
    accuracyCircleFillColor = ((Number) params.get("accuracyCircleFillColor")).intValue();

    userLocationLayer.setVisible(true);
    userLocationLayer.setHeadingEnabled(true);
    userLocationLayer.setObjectListener(yandexUserLocationObjectListener);
  }

  public void hideUserLayer() {
    if (!hasLocationPermission()) return;

    userLocationLayer.setVisible(false);
  }

  @SuppressWarnings("unchecked")
  public void setMapStyle(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    mapView.getMap().setMapStyle((String) params.get("style"));
  }

  @SuppressWarnings("unchecked")
  public void move(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsAnimation = ((Map<String, Object>) params.get("animation"));
    Map<String, Object> paramsCameraPostion = ((Map<String, Object>) params.get("cameraPosition"));
    Map<String, Object> paramsTarget = ((Map<String, Object>) paramsCameraPostion.get("target"));
    CameraPosition cameraPosition = new CameraPosition(
      pointFromJson(paramsTarget),
      ((Double) paramsCameraPostion.get("zoom")).floatValue(),
      ((Double) paramsCameraPostion.get("azimuth")).floatValue(),
      ((Double) paramsCameraPostion.get("tilt")).floatValue()
    );

    moveWithParams(paramsAnimation, cameraPosition);
  }

  @SuppressWarnings("unchecked")
  public void setBounds(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsAnimation = ((Map<String, Object>) params.get("animation"));
    Map<String, Object> paramsBoundingBox = (Map<String, Object>) params.get("boundingBox");
    Map<String, Object> southWest = (Map<String, Object>) paramsBoundingBox.get("southWest");
    Map<String, Object> northEast = (Map<String, Object>) paramsBoundingBox.get("northEast");
    CameraPosition cameraPosition = mapView.getMap().cameraPosition(new BoundingBox(
        pointFromJson(southWest),
        pointFromJson(northEast)
      )
    );

    moveWithParams(paramsAnimation, cameraPosition);
  }

  @SuppressWarnings("unchecked")
  public void addPlacemark(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsPoint = ((Map<String, Object>) params.get("point"));
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PlacemarkMapObject placemark = mapObjects.addPlacemark(pointFromJson(paramsPoint));

    applyPlacemarkStyle(placemark, paramsStyle);
    placemark.addTapListener(yandexMapObjectTapListener);
    placemark.setUserData(params.get("id"));
    placemark.setZIndex(((Double) params.get("zIndex")).floatValue());

    placemarks.add(placemark);
  }

  public Map<String, Object> getTargetPoint() {
    Point point =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();
    Map<String, Object> arguments = new HashMap<>();

    arguments.put("point", pointToJson(point));

    return arguments;
  }

  @SuppressWarnings("unchecked")
  public Map<String, Object> getVisibleRegion() {
    VisibleRegion region = mapView.getMap().getVisibleRegion();

    Map<String, Object> visibleRegionArguments = new HashMap<>();
    visibleRegionArguments.put("bottomLeft", pointToJson(region.getBottomLeft()));
    visibleRegionArguments.put("bottomRight", pointToJson(region.getBottomRight()));
    visibleRegionArguments.put("topLeft", pointToJson(region.getTopLeft()));
    visibleRegionArguments.put("topRight", pointToJson(region.getTopRight()));

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("visibleRegion", visibleRegionArguments);

    return arguments;
  }

  @SuppressWarnings("unchecked")
  public void removePlacemark(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    Iterator<PlacemarkMapObject> iterator = placemarks.iterator();

    while (iterator.hasNext()) {
      PlacemarkMapObject placemarkMapObject = iterator.next();
      if (placemarkMapObject.getUserData().equals(params.get("id"))) {
        mapObjects.remove(placemarkMapObject);
        iterator.remove();
      }
    }
  }

  @SuppressWarnings("unchecked")
  public void disableCameraTracking(MethodCall call) {
    if (yandexCameraListener != null) {
      mapView.getMap().removeCameraListener(yandexCameraListener);
      yandexCameraListener = null;
      if (cameraTarget != null) {
        MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
        mapObjects.remove(cameraTarget);
        cameraTarget = null;
      }
    }
  }

  @SuppressWarnings("unchecked")
  public Map<String, Object> enableCameraTracking(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();

    if (yandexCameraListener == null) {
      yandexCameraListener = new YandexCameraListener();
      mapView.getMap().addCameraListener(yandexCameraListener);
    }

    if (cameraTarget != null) {
      mapObjects.remove(cameraTarget);
      cameraTarget = null;
    }

    Point targetPoint =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("point", pointToJson(targetPoint));

    if (paramsStyle != null) {
      cameraTarget = mapObjects.addPlacemark(targetPoint);
      cameraTarget.addTapListener(yandexMapObjectTapListener);
      applyPlacemarkStyle(cameraTarget, paramsStyle);
    }

    return arguments;
  }

  @SuppressWarnings("unchecked")
  public void addPolyline(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    List<Map<String, Object>> paramsCoordinates = (List<Map<String, Object>>) params.get("coordinates");
    ArrayList<Point> polylineCoordinates = new ArrayList<>();
    for (Map<String, Object> c: paramsCoordinates) {
      polylineCoordinates.add(pointFromJson(c));
    }
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PolylineMapObject polyline = mapObjects.addPolyline(new Polyline(polylineCoordinates));

    polyline.addTapListener(yandexMapObjectTapListener);
    polyline.setUserData(params.get("id"));
    polyline.setGeodesic((boolean) params.get("isGeodesic"));
    polyline.setZIndex(((Double) params.get("zIndex")).floatValue());
    polyline.setOutlineColor(((Number) paramsStyle.get("outlineColor")).intValue());
    polyline.setOutlineWidth(((Double) paramsStyle.get("outlineWidth")).floatValue());
    polyline.setStrokeColor(((Number) paramsStyle.get("strokeColor")).intValue());
    polyline.setStrokeWidth(((Double) paramsStyle.get("strokeWidth")).floatValue());
    polyline.setDashLength(((Double) paramsStyle.get("dashLength")).floatValue());
    polyline.setDashOffset(((Double) paramsStyle.get("dashOffset")).floatValue());
    polyline.setGapLength(((Double) paramsStyle.get("gapLength")).floatValue());

    polylines.add(polyline);
  }

  @SuppressWarnings("unchecked")
  public void removePolyline(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    Iterator<PolylineMapObject> iterator = polylines.iterator();

    while (iterator.hasNext()) {
      PolylineMapObject polylineMapObject = iterator.next();
      if (polylineMapObject.getUserData().equals(params.get("id"))) {
        mapObjects.remove(polylineMapObject);
        iterator.remove();
      }
    }
  }

  @SuppressWarnings("unchecked")
  public void addPolygon(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    List<Map<String, Object>> paramsOuterRingCoordinates =
      (List<Map<String, Object>>) params.get("outerRingCoordinates");
    List<List<Map<String, Object>>> paramsInnerRingsCoordinates =
      (List<List<Map<String, Object>>>) params.get("innerRingsCoordinates");
    ArrayList<Point> outerRingPolygonPoints = new ArrayList<>();
    ArrayList<LinearRing> innerRings = new ArrayList<>();

    for (Map<String, Object> c: paramsOuterRingCoordinates) {
      outerRingPolygonPoints.add(pointFromJson(c));
    }

    for (List<Map<String, Object>> cl: paramsInnerRingsCoordinates) {
      ArrayList<Point> innerRingPolygonPoints = new ArrayList<>();

      for (Map<String, Object> c: cl) {
        innerRingPolygonPoints.add(pointFromJson(c));
      }

      innerRings.add(new LinearRing(innerRingPolygonPoints));
    }

    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PolygonMapObject polygon = mapObjects.addPolygon(new Polygon(new LinearRing(outerRingPolygonPoints), innerRings));

    polygon.addTapListener(yandexMapObjectTapListener);
    polygon.setUserData(params.get("id"));
    polygon.setGeodesic((boolean) params.get("isGeodesic"));
    polygon.setZIndex(((Double) params.get("zIndex")).floatValue());
    polygon.setGeodesic((boolean) params.get("isGeodesic"));
    polygon.setStrokeWidth(((Double) paramsStyle.get("strokeWidth")).floatValue());
    polygon.setStrokeColor(((Number) paramsStyle.get("strokeColor")).intValue());
    polygon.setFillColor(((Number) paramsStyle.get("fillColor")).intValue());

    polygons.add(polygon);
  }

  @SuppressWarnings("unchecked")
  public void removePolygon(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    Iterator<PolygonMapObject> iterator = polygons.iterator();

    while (iterator.hasNext()) {
      PolygonMapObject polygonMapObject = iterator.next();
      if (polygonMapObject.getUserData().equals(params.get("id"))) {
        mapObjects.remove(polygonMapObject);
        iterator.remove();
      }
    }
  }

  @SuppressWarnings("unchecked")
  public void addCircle(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsCenter = (Map<String, Object>) params.get("center");
    Double paramsRadius = (Double) params.get("radius");
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();

    CircleMapObject circle = mapObjects.addCircle(
      new Circle(pointFromJson(paramsCenter), paramsRadius.floatValue()),
      ((Number) paramsStyle.get("strokeColor")).intValue(),
      ((Double) paramsStyle.get("strokeWidth")).floatValue(),
      ((Number) paramsStyle.get("fillColor")).intValue()
    );

    circle.addTapListener(yandexMapObjectTapListener);
    circle.setUserData(params.get("id"));
    circle.setGeodesic((boolean) params.get("isGeodesic"));
    circle.setZIndex(((Double) params.get("zIndex")).floatValue());

    circles.add(circle);
  }

  @SuppressWarnings("unchecked")
  public void removeCircle(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    Iterator<CircleMapObject> iterator = circles.iterator();

    while (iterator.hasNext()) {
      CircleMapObject circleMapObject = iterator.next();
      if (circleMapObject.getUserData().equals(params.get("id"))) {
        mapObjects.remove(circleMapObject);
        iterator.remove();
      }
    }
  }

  public Map<String, Object> getUserTargetPoint() {
    if (!hasLocationPermission()) return null;

    if (userLocationLayer != null) {
      CameraPosition cameraPosition = userLocationLayer.cameraPosition();

      if (cameraPosition != null) {
        Point point =  cameraPosition.getTarget();
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("point", pointToJson(point));

        return arguments;
      }
    }

    return null;
  }

  public void zoomIn() {
    zoom(1f);
  }

  public void zoomOut() {
    zoom(-1f);
  }

  public boolean isZoomGesturesEnabled() {
    return mapView.getMap().isZoomGesturesEnabled();
  }

  @SuppressWarnings("unchecked")
  public void toggleZoomGestures(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    boolean enabled = (Boolean) params.get("enabled");

    mapView.getMap().setZoomGesturesEnabled(enabled);
  }

  public float getMinZoom() {
    return mapView.getMap().getMinZoom();
  }

  public float getMaxZoom() {
    return mapView.getMap().getMaxZoom();
  }

  public float getZoom() {
    return mapView.getMap().getCameraPosition().getZoom();
  }

  public boolean isTiltGesturesEnabled() {
    return mapView.getMap().isTiltGesturesEnabled();
  }

  @SuppressWarnings("unchecked")
  public void toggleTiltGestures(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    boolean enabled = (Boolean) params.get("enabled");

    mapView.getMap().setTiltGesturesEnabled(enabled);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "waitForInit":
        result.success(null);
        break;
      case "logoAlignment":
        logoAlignment(call);
        result.success(null);
        break;
      case "toggleNightMode":
        toggleNightMode(call);
        result.success(null);
        break;
      case "toggleMapRotation":
        toggleMapRotation(call);
        result.success(null);
        break;
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
      case "setFocusRect":
        setFocusRect(call);
        result.success(null);
        break;
      case "clearFocusRect":
        clearFocusRect();
        result.success(null);
        break;
      case "enableCameraTracking":
        Map<String, Object> target = enableCameraTracking(call);
        result.success(target);
        break;
      case "disableCameraTracking":
        disableCameraTracking(call);
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
      case "addPolygon":
        addPolygon(call);
        result.success(null);
        break;
      case "removePolygon":
        removePolygon(call);
        result.success(null);
        break;
      case "addCircle":
        addCircle(call);
        result.success(null);
        break;
      case "removeCircle":
        removeCircle(call);
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
      case "isZoomGesturesEnabled":
        boolean isZoomGesturesEnabledValue = isZoomGesturesEnabled();
        result.success(isZoomGesturesEnabledValue);
        break;
      case "toggleZoomGestures":
        toggleZoomGestures(call);
        result.success(null);
        break;
      case "getMinZoom":
        float minZoom = getMinZoom();
        result.success(minZoom);
        break;
      case "getMaxZoom":
        float maxZoom = getMaxZoom();
        result.success(maxZoom);
        break;
      case "getZoom":
        float zoom = getZoom();
        result.success(zoom);
        break;
      case "getTargetPoint":
        Map<String, Object> targetPoint = getTargetPoint();
        result.success(targetPoint);
        break;
      case "getVisibleRegion":
        Map<String, Object> region = getVisibleRegion();
        result.success(region);
        break;
      case "getUserTargetPoint":
        Map<String, Object> userTargetPoint = getUserTargetPoint();
        result.success(userTargetPoint);
        break;
      case "isTiltGesturesEnabled":
        boolean isTiltGesturesEnabledValue = isTiltGesturesEnabled();
        result.success(isTiltGesturesEnabledValue);
        break;
      case "toggleTiltGestures":
        toggleTiltGestures(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }

    mapView.onStart();
  }

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {}

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }

    mapView.onStop();
  }

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {
    owner.getLifecycle().removeObserver(this);

    if (disposed) {
      return;
    }
  }

  private boolean hasLocationPermission() {
    int permissionState = ActivityCompat.checkSelfPermission(
      mapView.getContext(),
      Manifest.permission.ACCESS_FINE_LOCATION
    );
    return permissionState == PackageManager.PERMISSION_GRANTED;
  }

  @SuppressWarnings("unchecked")
  private void moveWithParams(Map<String, Object> paramsAnimation, CameraPosition cameraPosition) {
    if (paramsAnimation == null) {
      mapView.getMap().move(cameraPosition);
      return;
    }

    Animation.Type type = ((Boolean) paramsAnimation.get("smooth")) ?
      Animation.Type.SMOOTH :
      Animation.Type.LINEAR;
    Animation animation = new Animation(type, ((Double) paramsAnimation.get("duration")).floatValue());

    mapView.getMap().move(cameraPosition, animation, null);
  }

  private void zoom(float step) {
    Point zoomPoint = mapView.getMap().getCameraPosition().getTarget();
    float currentZoom = mapView.getMap().getCameraPosition().getZoom();
    float tilt = mapView.getMap().getCameraPosition().getTilt();
    float azimuth = mapView.getMap().getCameraPosition().getAzimuth();
    mapView.getMap().move(
      new CameraPosition(
        zoomPoint,
        currentZoom + step,
        tilt,
        azimuth
      ),
      new Animation(Animation.Type.SMOOTH, 1),
      null
    );
  }

  @SuppressWarnings("unchecked")
  private Point pointFromJson(Map<String, Object> json) {
    return new Point(((Double) json.get("latitude")), ((Double) json.get("longitude")));
  }

  private Map<String, Double> pointToJson(Point point) {
    Map<String, Double> pointMap = new HashMap<>();
    pointMap.put("latitude", point.getLatitude());
    pointMap.put("longitude", point.getLongitude());

    return pointMap;
  }

  private void applyPlacemarkStyle(PlacemarkMapObject placemark, Map<String, Object> params) {
  
    placemark.setUserData(params.get("id"));
  
    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDirection(((Double) params.get("direction")).floatValue());
  
    if (params.get("zIndex") != null) {
      placemark.setZIndex((float) params.get("zIndex"));
    }
  
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
      FlutterLoader loader = FlutterInjector.instance().flutterLoader();
      img = ImageProvider.fromAsset(mapView.getContext(), loader.getLookupKeyForAsset(iconName));
    } else {
      Bitmap bitmapData = BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length);
      img = ImageProvider.fromBitmap(bitmapData);
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
      
      if (tappableAreaMin != null && tappableAreaMax != null) {
        
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
    }
    
    return iconStyle;
  }

  private class YandexCameraListener implements CameraListener {
    @Override
    public void onCameraPositionChanged(
      com.yandex.mapkit.map.Map map,
      CameraPosition cameraPosition,
      CameraUpdateReason cameraUpdateReason,
      boolean finished
    ) {
      Point targetPoint = cameraPosition.getTarget();

      if (cameraTarget != null) {
        cameraTarget.setGeometry(targetPoint);
      }

      Map<String, Object> cameraPositionArguments = new HashMap<>();
      cameraPositionArguments.put("target", pointToJson(targetPoint));
      cameraPositionArguments.put("zoom", cameraPosition.getZoom());
      cameraPositionArguments.put("tilt", cameraPosition.getTilt());
      cameraPositionArguments.put("azimuth", cameraPosition.getAzimuth());

      Map<String, Object> arguments = new HashMap<>();
      arguments.put("cameraPosition", cameraPositionArguments);
      arguments.put("finished", finished);

      methodChannel.invokeMethod("onCameraPositionChanged", arguments);
    }
  }

  private class YandexUserLocationObjectListener implements UserLocationObjectListener {
    public void onObjectAdded(UserLocationView view) {
      view.getPin().setIcon(
        ImageProvider.fromAsset(mapView.getContext(), FlutterMain.getLookupKeyForAsset(userLocationIconName))
      );
      view.getArrow().setIcon(
        ImageProvider.fromAsset(mapView.getContext(), FlutterMain.getLookupKeyForAsset(userArrowIconName))
      );
      if (userArrowOrientation) {
        view.getArrow().setIconStyle(new IconStyle().setRotationType(RotationType.ROTATE));
      }
      view.getAccuracyCircle().setFillColor(accuracyCircleFillColor);
    }

    public void onObjectRemoved(UserLocationView view) {}

    public void onObjectUpdated(UserLocationView view, ObjectEvent event) {}
  }

  private class YandexMapObjectTapListener implements MapObjectTapListener {
    public boolean onMapObjectTap(MapObject mapObject, Point point) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("id", mapObject.getUserData());
      arguments.put("point", pointToJson(point));

      methodChannel.invokeMethod("onMapObjectTap", arguments);

      return true;
    }
  }

  private class YandexMapInputListener implements InputListener {
    public void onMapTap(com.yandex.mapkit.map.Map map, Point point) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("point", pointToJson(point));

      methodChannel.invokeMethod("onMapTap", arguments);
    }

    public void onMapLongTap(com.yandex.mapkit.map.Map map, Point point) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("point", pointToJson(point));

      methodChannel.invokeMethod("onMapLongTap", arguments);
    }
  }

  private class YandexMapSizeChangedListener implements SizeChangedListener {
    public void onMapWindowSizeChanged(com.yandex.mapkit.map.MapWindow mapWindow, int newWidth, int newHeight) {
      Map<String, Object> mapSizeArguments = new HashMap<>();
      mapSizeArguments.put("width", newWidth);
      mapSizeArguments.put("height", newHeight);

      Map<String, Object> arguments = new HashMap<>();
      arguments.put("mapSize", mapSizeArguments);

      methodChannel.invokeMethod("onMapSizeChanged", arguments);
    }
  }
}
