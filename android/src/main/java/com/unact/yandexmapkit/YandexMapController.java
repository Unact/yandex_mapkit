package com.unact.yandexmapkit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.view.View;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PointF;
import androidx.core.app.ActivityCompat;

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

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.view.FlutterMain;


public class YandexMapController implements PlatformView, MethodChannel.MethodCallHandler {
  private final MapView mapView;
  private final MethodChannel methodChannel;
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

  public YandexMapController(int id, Context context, BinaryMessenger messenger) {
    MapKitFactory.initialize(context);
    mapView = new MapView(context);
    MapKitFactory.getInstance().onStart();
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
  private void toggleNightMode(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMap().setNightModeEnabled((Boolean) params.get("enabled"));
  }

  @SuppressWarnings("unchecked")
  private void toggleMapRotation(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMap().setRotateGesturesEnabled((Boolean) params.get("enabled"));
  }

  @SuppressWarnings("unchecked")
  private void setFocusRect(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsTopLeftScreenPoint = ((Map<String, Object>) params.get("topLeftScreenPoint"));
    Map<String, Object> paramsBottomRightScreenPoint = ((Map<String, Object>) params.get("bottomRightScreenPoint"));
    ScreenRect screenRect = new ScreenRect(
      new ScreenPoint(
        ((Double) paramsTopLeftScreenPoint.get("x")).floatValue(),
        ((Double) paramsTopLeftScreenPoint.get("y")).floatValue()
      ),
      new ScreenPoint(
        ((Double) paramsBottomRightScreenPoint.get("x")).floatValue(),
        ((Double) paramsBottomRightScreenPoint.get("y")).floatValue()
      )
    );

    mapView.setFocusRect(screenRect);
    mapView.setPointOfView(PointOfView.ADAPT_TO_FOCUS_RECT_HORIZONTALLY);
  }

  private void clearFocusRect() {
    mapView.setFocusRect(null);
    mapView.setPointOfView(PointOfView.SCREEN_CENTER);
  }

  @SuppressWarnings("unchecked")
  private void logoAlignment(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Alignment logoPosition = new Alignment(
      HorizontalAlignment.values()[(Integer) params.get("x")],
      VerticalAlignment.values()[(Integer) params.get("y")]
    );
    mapView.getMap().getLogo().setAlignment(logoPosition);
  }

  @SuppressWarnings("unchecked")
  private void showUserLayer(MethodCall call) {

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
    Map<String, Object> paramsPoint = ((Map<String, Object>) params.get("point"));
    Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));
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
    Map<String, Object> paramsSouthWestPoint = ((Map<String, Object>) params.get("southWestPoint"));
    Map<String, Object> paramsNorthEastPoint = ((Map<String, Object>) params.get("northEastPoint"));
    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) paramsSouthWestPoint.get("latitude")), ((Double) paramsSouthWestPoint.get("longitude"))),
      new Point(((Double) paramsNorthEastPoint.get("latitude")), ((Double) paramsNorthEastPoint.get("longitude")))
    );

    moveWithParams(params, mapView.getMap().cameraPosition(boundingBox));
  }

  @SuppressWarnings("unchecked")
  private void addPlacemark(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsPoint = ((Map<String, Object>) params.get("point"));
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PlacemarkMapObject placemark = mapObjects.addPlacemark(point);
    String iconName = (String) paramsStyle.get("iconName");
    byte[] rawImageData = (byte[]) paramsStyle.get("rawImageData");

    placemark.setUserData(params.get("hashCode"));
    placemark.setOpacity(((Double) paramsStyle.get("opacity")).floatValue());
    placemark.setDraggable((Boolean) paramsStyle.get("isDraggable"));
    placemark.setDirection(((Double) paramsStyle.get("direction")).floatValue());
    placemark.addTapListener(yandexMapObjectTapListener);

    if (iconName != null) {
      placemark.setIcon(ImageProvider.fromAsset(mapView.getContext(), FlutterMain.getLookupKeyForAsset(iconName)));
    }

    if (rawImageData != null) {
      Bitmap bitmapData = BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length);
      placemark.setIcon(ImageProvider.fromBitmap(bitmapData));
    }

    IconStyle iconStyle = new IconStyle();
    iconStyle.setAnchor(
      new PointF(
        ((Double) paramsStyle.get("anchorX")).floatValue(),
        ((Double) paramsStyle.get("anchorY")).floatValue()
      )
    );
    iconStyle.setZIndex(((Double) paramsStyle.get("zIndex")).floatValue());
    iconStyle.setScale(((Double) paramsStyle.get("scale")).floatValue());

    int rotationType = ((Number) paramsStyle.get("rotationType")).intValue();
    if (rotationType == RotationType.ROTATE.ordinal()) {
      iconStyle.setRotationType(RotationType.ROTATE);
    }

    placemark.setIconStyle(iconStyle);

    placemarks.add(placemark);
  }

  private Map<String, Object> getTargetPoint() {
    Point point =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("latitude", point.getLatitude());
    arguments.put("longitude", point.getLongitude());
    return arguments;
  }

  @SuppressWarnings("unchecked")
  private Map<String, Object> getVisibleRegion() {
    final VisibleRegion region = mapView.getMap().getVisibleRegion();
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("bottomLeftPoint", new HashMap<String, Double>() {{
      put("latitude", region.getBottomLeft().getLatitude());
      put("longitude", region.getBottomLeft().getLongitude());
    }});
    arguments.put("bottomRightPoint", new HashMap<String, Double>() {{
      put("latitude", region.getBottomRight().getLatitude());
      put("longitude", region.getBottomRight().getLongitude());
    }});
    arguments.put("topLeftPoint", new HashMap<String, Double>() {{
      put("latitude", region.getTopLeft().getLatitude());
      put("longitude", region.getTopLeft().getLongitude());
    }});
    arguments.put("topRightPoint", new HashMap<String, Double>() {{
      put("latitude", region.getTopRight().getLatitude());
      put("longitude", region.getTopRight().getLongitude());
    }});
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

  @SuppressWarnings("unchecked")
  private void disableCameraTracking(MethodCall call) {
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
  private Map<String, Object> enableCameraTracking(MethodCall call) {
    if (yandexCameraListener == null) {
      yandexCameraListener = new YandexCameraListener();
      mapView.getMap().addCameraListener(yandexCameraListener);
    }

    if (cameraTarget != null) {
      MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
      mapObjects.remove(cameraTarget);
      cameraTarget = null;
    }

    Point targetPoint =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();
    if (call.arguments != null) {
      Map<String, Object> params = ((Map<String, Object>) call.arguments);
      Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));

      MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
      cameraTarget = mapObjects.addPlacemark(targetPoint);
      String iconName = (String) paramsStyle.get("iconName");
      byte[] rawImageData = (byte[]) paramsStyle.get("rawImageData");
      cameraTarget.setOpacity(((Double) paramsStyle.get("opacity")).floatValue());
      cameraTarget.setDraggable((Boolean) paramsStyle.get("isDraggable"));
      cameraTarget.addTapListener(yandexMapObjectTapListener);

      if (iconName != null) {
        cameraTarget.setIcon(ImageProvider.fromAsset(mapView.getContext(), FlutterMain.getLookupKeyForAsset(iconName)));
      }

      if (rawImageData != null) {
        Bitmap bitmapData = BitmapFactory.decodeByteArray(rawImageData, 0, rawImageData.length);
        cameraTarget.setIcon(ImageProvider.fromBitmap(bitmapData));
      }

      IconStyle iconStyle = new IconStyle();
      iconStyle.setAnchor(
        new PointF(
          ((Double) paramsStyle.get("anchorX")).floatValue(),
          ((Double) paramsStyle.get("anchorY")).floatValue()
        )
      );
      iconStyle.setZIndex(((Double) paramsStyle.get("zIndex")).floatValue());
      iconStyle.setScale(((Double) paramsStyle.get("scale")).floatValue());
      cameraTarget.setIconStyle(iconStyle);
    }

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("latitude", targetPoint.getLatitude());
    arguments.put("longitude", targetPoint.getLongitude());
    return arguments;
  }

  @SuppressWarnings("unchecked")
  private void addPolyline(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    List<Map<String, Object>> paramsCoordinates = (List<Map<String, Object>>) params.get("coordinates");
    ArrayList<Point> polylineCoordinates = new ArrayList<>();
    for (Map<String, Object> c: paramsCoordinates) {
      Point p = new Point((Double) c.get("latitude"), (Double) c.get("longitude"));
      polylineCoordinates.add(p);
    }
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PolylineMapObject polyline = mapObjects.addPolyline(new Polyline(polylineCoordinates));

    polyline.setUserData(params.get("hashCode"));
    polyline.setOutlineColor(((Number) paramsStyle.get("outlineColor")).intValue());
    polyline.setOutlineWidth(((Double) paramsStyle.get("outlineWidth")).floatValue());
    polyline.setStrokeColor(((Number) paramsStyle.get("strokeColor")).intValue());
    polyline.setStrokeWidth(((Double) paramsStyle.get("strokeWidth")).floatValue());
    polyline.setGeodesic((boolean) paramsStyle.get("isGeodesic"));
    polyline.setDashLength(((Double) paramsStyle.get("dashLength")).floatValue());
    polyline.setDashOffset(((Double) paramsStyle.get("dashOffset")).floatValue());
    polyline.setGapLength(((Double) paramsStyle.get("gapLength")).floatValue());

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

  @SuppressWarnings("unchecked")
  private void addPolygon(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));
    List<Map<String, Object>> paramsOuterRingCoordinates =
      (List<Map<String, Object>>) params.get("outerRingCoordinates");
    List<List<Map<String, Object>>> paramsInnerRingsCoordinates =
      (List<List<Map<String, Object>>>) params.get("innerRingsCoordinates");
    ArrayList<Point> outerRingPolygonPoints = new ArrayList<>();
    ArrayList<LinearRing> innerRings = new ArrayList<>();

    for (Map<String, Object> c: paramsOuterRingCoordinates) {
      Point point = new Point(((Double) c.get("latitude")), ((Double) c.get("longitude")));
      outerRingPolygonPoints.add(point);
    }
    for (List<Map<String, Object>> cl: paramsInnerRingsCoordinates) {
      ArrayList<Point> innerRingPolygonPoints = new ArrayList<>();

      for (Map<String, Object> c: cl) {
        Point point = new Point(((Double) c.get("latitude")), ((Double) c.get("longitude")));
        innerRingPolygonPoints.add(point);
      }

      innerRings.add(new LinearRing(innerRingPolygonPoints));
    }

    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    PolygonMapObject polygon = mapObjects.addPolygon(new Polygon(new LinearRing(outerRingPolygonPoints), innerRings));

    polygon.setUserData(params.get("hashCode"));
    polygon.setStrokeWidth(((Double) paramsStyle.get("strokeWidth")).floatValue());
    polygon.setStrokeColor(((Number) paramsStyle.get("strokeColor")).intValue());
    polygon.setFillColor(((Number) paramsStyle.get("fillColor")).intValue());

    polygons.add(polygon);
  }

  @SuppressWarnings("unchecked")
  private void removePolygon(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();
    Iterator<PolygonMapObject> iterator = polygons.iterator();

    while (iterator.hasNext()) {
      PolygonMapObject polygonMapObject = iterator.next();
      if (polygonMapObject.getUserData().equals(params.get("hashCode"))) {
        mapObjects.remove(polygonMapObject);
        iterator.remove();
      }
    }
  }

  @SuppressWarnings("unchecked")
  private void addCircle(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Map<String, Object> paramsCenter = (Map<String, Object>) params.get("center");
    Double paramsRadius = (Double) params.get("radius");
    Map<String, Object> paramsStyle = ((Map<String, Object>) params.get("style"));

    Point circleCenter = new Point((Double) paramsCenter.get("latitude"), (Double) paramsCenter.get("longitude"));
    Float circleRadius = paramsRadius.floatValue();

    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();

    CircleMapObject circle = mapObjects.addCircle(
      new Circle(circleCenter, circleRadius),
      ((Number) paramsStyle.get("strokeColor")).intValue(),
      ((Double) paramsStyle.get("strokeWidth")).floatValue(),
      ((Number) paramsStyle.get("fillColor")).intValue());

    circle.setUserData(params.get("hashCode"));
    circle.setGeodesic((boolean) paramsStyle.get("isGeodesic"));

    circles.add(circle);
  }

  @SuppressWarnings("unchecked")
  private void removeCircle(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();

    Iterator<CircleMapObject> iterator = circles.iterator();

    while (iterator.hasNext()) {
      CircleMapObject circleMapObject = iterator.next();
      if (circleMapObject.getUserData().equals(params.get("hashCode"))) {
        mapObjects.remove(circleMapObject);
        iterator.remove();
      }
    }
  }

  private Map<String, Object> getUserTargetPoint() {
    if (!hasLocationPermission()) return null;

    if (userLocationLayer != null) {
      CameraPosition cameraPosition = userLocationLayer.cameraPosition();

      if (cameraPosition != null) {
        Point point =  cameraPosition.getTarget();
        Map<String, Object> arguments = new HashMap<>();

        arguments.put("latitude", point.getLatitude());
        arguments.put("longitude", point.getLongitude());

        return arguments;
      }
    }

    return null;
  }

  private void moveWithParams(Map<String, Object> params, CameraPosition cameraPosition) {
    Map<String, Object> paramsAnimation = ((Map<String, Object>) params.get("animation"));
    if (((Boolean) paramsAnimation.get("animate"))) {
      Animation.Type type = ((Boolean) paramsAnimation.get("smoothAnimation")) ?
        Animation.Type.SMOOTH :
        Animation.Type.LINEAR;
      Animation animation = new Animation(type, ((Double) paramsAnimation.get("animationDuration")).floatValue());

      mapView.getMap().move(cameraPosition, animation, null);
    } else {
      mapView.getMap().move(cameraPosition);
    }
  }

  private boolean hasLocationPermission() {
    int permissionState = ActivityCompat.checkSelfPermission(
      mapView.getContext(),
      Manifest.permission.ACCESS_FINE_LOCATION
    );
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
        currentZoom + step,
        tilt,
        azimuth
      ),
      new Animation(Animation.Type.SMOOTH, 1),
      null
    );
  }

  private boolean isZoomGesturesEnabled() {
    return mapView.getMap().isZoomGesturesEnabled();
  }

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
  
  private boolean isTiltGesturesEnabled() {
    return mapView.getMap().isTiltGesturesEnabled();
  }
    
  public void toggleTiltGestures(MethodCall call) {
    
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    boolean enabled = (Boolean) params.get("enabled");
    
    mapView.getMap().setTiltGesturesEnabled(enabled);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
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
        boolean isZoomGesturesEnabled = isZoomGesturesEnabled();
        result.success(isZoomGesturesEnabled);
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
        boolean isTiltGesturesEnabled = isTiltGesturesEnabled();
        result.success(isTiltGesturesEnabled);
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

  private class YandexCameraListener implements CameraListener {
    @Override
    public void onCameraPositionChanged(
      com.yandex.mapkit.map.Map map,
      CameraPosition cameraPosition,
      CameraUpdateReason cameraUpdateReason,
      boolean bFinal
    ) {
      Point targetPoint = cameraPosition.getTarget();
      if (cameraTarget != null) {
        cameraTarget.setGeometry(targetPoint);
      }
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("latitude", targetPoint.getLatitude());
      arguments.put("longitude", targetPoint.getLongitude());
      arguments.put("zoom", cameraPosition.getZoom());
      arguments.put("tilt", cameraPosition.getTilt());
      arguments.put("azimuth", cameraPosition.getAzimuth());
      arguments.put("final", bFinal);

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
      arguments.put("hashCode", mapObject.getUserData());
      arguments.put("latitude", point.getLatitude());
      arguments.put("longitude", point.getLongitude());

      methodChannel.invokeMethod("onMapObjectTap", arguments);

      return false;
    }
  }

  private class YandexMapInputListener implements InputListener {
    public void onMapTap(com.yandex.mapkit.map.Map map, Point point) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("latitude", point.getLatitude());
      arguments.put("longitude", point.getLongitude());

      methodChannel.invokeMethod("onMapTap", arguments);
    }

    public void onMapLongTap(com.yandex.mapkit.map.Map map, Point point) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("latitude", point.getLatitude());
      arguments.put("longitude", point.getLongitude());

      methodChannel.invokeMethod("onMapLongTap", arguments);
    }
  }

  private class YandexMapSizeChangedListener implements SizeChangedListener {
    public void onMapWindowSizeChanged(com.yandex.mapkit.map.MapWindow mapWindow, int newWidth, int newHeight) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("width", newWidth);
      arguments.put("height", newHeight);

      methodChannel.invokeMethod("onMapSizeChanged", arguments);
    }
  }
}
