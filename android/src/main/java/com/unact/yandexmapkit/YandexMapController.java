package com.unact.yandexmapkit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.yandex.mapkit.Animation;
import com.yandex.mapkit.GeoObject;
import com.yandex.mapkit.MapKitFactory;
import com.yandex.mapkit.ScreenPoint;
import com.yandex.mapkit.ScreenRect;
import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.layers.GeoObjectTapEvent;
import com.yandex.mapkit.layers.GeoObjectTapListener;
import com.yandex.mapkit.layers.ObjectEvent;
import com.yandex.mapkit.logo.Alignment;
import com.yandex.mapkit.logo.HorizontalAlignment;
import com.yandex.mapkit.logo.VerticalAlignment;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.GeoObjectSelectionMetadata;
import com.yandex.mapkit.map.InputListener;
import com.yandex.mapkit.map.MapType;
import com.yandex.mapkit.map.PointOfView;
import com.yandex.mapkit.map.CameraUpdateReason;
import com.yandex.mapkit.map.CameraListener;
import com.yandex.mapkit.mapview.MapView;
import com.yandex.mapkit.traffic.TrafficLayer;
import com.yandex.mapkit.traffic.TrafficLevel;
import com.yandex.mapkit.traffic.TrafficListener;
import com.yandex.mapkit.user_location.UserLocationLayer;
import com.yandex.mapkit.user_location.UserLocationObjectListener;
import com.yandex.mapkit.user_location.UserLocationView;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.FlutterException;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class YandexMapController implements
  PlatformView,
  MethodChannel.MethodCallHandler,
  DefaultLifecycleObserver,
  UserLocationObjectListener,
  TrafficListener,
  InputListener,
  CameraListener,
  GeoObjectTapListener,
  View.OnLayoutChangeListener
{
  private final MapView mapView;
  public final Context context;
  public final MethodChannel methodChannel;
  private final YandexMapkitPlugin.LifecycleProvider lifecycleProvider;
  private final TrafficLayer trafficLayer;
  private final UserLocationLayer userLocationLayer;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private PlacemarkMapObjectController userPinController;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private PlacemarkMapObjectController userArrowController;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private CircleMapObjectController userAccuracyCircleController;
  private final MapObjectCollectionController rootController;
  private boolean disposed = false;
  private MethodChannel.Result initResult;

  @SuppressWarnings({"unchecked", "ConstantConditions", "InflateParams"})
  public YandexMapController(
    int id,
    Context context,
    BinaryMessenger messenger,
    Map<String, Object> params,
    YandexMapkitPlugin.LifecycleProvider lifecycleProvider
  ) {
    this.lifecycleProvider = lifecycleProvider;
    this.context = context;

    if (context instanceof FlutterActivity) {
      mapView = (MapView) ((FlutterActivity) context).getLayoutInflater().inflate(R.layout.map_view, null);
    } else if (context instanceof FlutterFragmentActivity) {
      mapView = (MapView) ((FlutterFragmentActivity) context).getLayoutInflater().inflate(R.layout.map_view, null);
    } else {
      mapView = new MapView(context);
    }

    mapView.onStart();

    userLocationLayer = MapKitFactory.getInstance().createUserLocationLayer(mapView.getMapWindow());
    trafficLayer = MapKitFactory.getInstance().createTrafficLayer(mapView.getMapWindow());

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_map_" + id);
    methodChannel.setMethodCallHandler(this);

    rootController = new MapObjectCollectionController(
      mapView.getMap().getMapObjects(),
      "root_map_object_collection",
      new WeakReference<>(this)
    );

    mapView.getMap().addInputListener(this);
    mapView.getMap().addCameraListener(this);
    mapView.getMap().addTapListener(this);
    mapView.addOnLayoutChangeListener(this);

    lifecycleProvider.getLifecycle().addObserver(this);
    userLocationLayer.setObjectListener(this);
    trafficLayer.addTrafficListener(this);

    applyMapOptions((Map<String, Object>) params.get("mapOptions"));
    applyMapObjects((Map<String, Object>) params.get("mapObjects"));
  }

  @Override
  public View getView() {
    return mapView;
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "waitForInit":
        if (mapView.getWidth() == 0 || mapView.getHeight() == 0) {
          initResult = result;
        } else {
          result.success(null);
        }
        break;
      case "toggleUserLayer":
        toggleUserLayer(call);
        result.success(null);
        break;
      case "toggleTrafficLayer":
        toggleTrafficLayer(call);
        result.success(null);
        break;
      case "setMapStyle":
        result.success(setMapStyle(call));
        break;
      case "moveCamera":
        moveCamera(call, result);
        break;
      case "updateMapObjects":
        updateMapObjects(call);
        result.success(null);
        break;
      case "updateMapOptions":
        updateMapOptions(call);
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
      case "getPoint":
        result.success(getPoint(call));
        break;
      case "getScreenPoint":
        result.success(getScreenPoint(call));
        break;
      case "getCameraPosition":
        result.success(getCameraPosition());
        break;
      case "getVisibleRegion":
        result.success(getVisibleRegion());
        break;
      case "getFocusRegion":
        result.success(getFocusRegion());
        break;
      case "getUserCameraPosition":
        result.success(getUserCameraPosition());
        break;
      case "selectGeoObject":
        selectGeoObject(call);
        result.success(null);
        break;
      case "deselectGeoObject":
        deselectGeoObject();
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings({"unchecked"})
  public void updateMapObjects(MethodCall call) {
    Map<String, Object> params = (Map<String, Object>) call.arguments;

    applyMapObjects(params);
  }

  @SuppressWarnings({"unchecked"})
  public void updateMapOptions(MethodCall call) {
    Map<String, Object> params = (Map<String, Object>) call.arguments;

    applyMapOptions(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void toggleUserLayer(MethodCall call) {
    if (!hasLocationPermission()) return;

    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> anchor = (Map<String, Object>) params.get("anchor");

    userLocationLayer.setVisible((Boolean) params.get("visible"));
    userLocationLayer.setHeadingEnabled((Boolean) params.get("headingEnabled"));
    userLocationLayer.setAutoZoomEnabled((Boolean) params.get("autoZoomEnabled"));
    userLocationLayer.resetAnchor();

    if (anchor != null) {
      userLocationLayer.setAnchor(
        Utils.rectPointFromJson((Map<String, Double>) anchor.get("normal")),
        Utils.rectPointFromJson((Map<String, Double>) anchor.get("course"))
      );
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void toggleTrafficLayer(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    trafficLayer.setTrafficVisible((Boolean) params.get("visible"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public boolean setMapStyle(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    return mapView.getMap().setMapStyle((String) params.get("style"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void selectGeoObject(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMapWindow().getMap().selectGeoObject(
      (String) params.get("objectId"),
      (String) params.get("layerId")
    );
  }

  public void deselectGeoObject() {
    mapView.getMapWindow().getMap().deselectGeoObject();
  }

  public float getMinZoom() {
    return mapView.getMap().getMinZoom();
  }

  public float getMaxZoom() {
    return mapView.getMap().getMaxZoom();
  }

  @SuppressWarnings({"unchecked"})
  public Map<String, Float> getScreenPoint(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    ScreenPoint screenPoint = mapView.getMapWindow().worldToScreen(Utils.pointFromJson(params));

    if (screenPoint != null) {
      return Utils.screenPointToJson(screenPoint);
    }

    return null;
  }

  @SuppressWarnings({"unchecked"})
  public Map<String, Double> getPoint(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Point point = mapView.getMapWindow().screenToWorld(Utils.screenPointFromJson(params));

    if (point != null) {
      return Utils.pointToJson(point);
    }

    return null;
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void moveCamera(MethodCall call, MethodChannel.Result result) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    if (mapView.getWidth() == 0 || mapView.getHeight() == 0) {
      result.success(false);

      return;
    }

    move(
      cameraUpdateToPosition((Map<String, Object>) params.get("cameraUpdate")),
      ((Map<String, Object>) params.get("animation")),
      result
    );
  }

  public Map<String, Object> getCameraPosition() {
    Map<String, Object> arguments = new HashMap<>();

    arguments.put("cameraPosition", Utils.cameraPositionToJson(mapView.getMapWindow().getMap().getCameraPosition()));

    return arguments;
  }

  public Map<String, Object> getUserCameraPosition() {
    if (!hasLocationPermission()) return null;

    if (userLocationLayer != null) {
      CameraPosition cameraPosition = userLocationLayer.cameraPosition();

      if (cameraPosition != null) {
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("cameraPosition", Utils.cameraPositionToJson(cameraPosition));

        return arguments;
      }
    }

    return null;
  }

  public Map<String, Object> getVisibleRegion() {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("visibleRegion", Utils.visibleRegionToJson(mapView.getMap().getVisibleRegion()));

    return arguments;
  }

  public Map<String, Object> getFocusRegion() {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("focusRegion", Utils.visibleRegionToJson(mapView.getMapWindow().getFocusRegion()));

    return arguments;
  }

  @SuppressWarnings("BooleanMethodIsAlwaysInverted")
  private boolean hasLocationPermission() {
    int permissionState = ActivityCompat.checkSelfPermission(
      context,
      Manifest.permission.ACCESS_FINE_LOCATION
    );
    return permissionState == PackageManager.PERMISSION_GRANTED;
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private CameraPosition cameraUpdateToPosition(Map<String, Object> cameraUpdate) {
    Map<String, Object> cameraUpdateParams = ((Map<String, Object>) cameraUpdate.get("params"));

    switch ((String) cameraUpdate.get("type")) {
      case "newCameraPosition":
        return newCameraPosition(cameraUpdateParams);
      case "newBounds":
        return newBounds(cameraUpdateParams);
      case "newTiltAzimuthGeometry":
        return newTiltAzimuthGeometry(cameraUpdateParams);
      case "zoomIn":
        return zoomIn();
      case "zoomOut":
        return zoomOut();
      case "zoomTo":
        return zoomTo(cameraUpdateParams);
      case "azimuthTo":
        return azimuthTo(cameraUpdateParams);
      case "tiltTo":
        return tiltTo(cameraUpdateParams);
      default:
        return new CameraPosition();
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public CameraPosition newCameraPosition(Map<String, Object> params) {
    Map<String, Object> paramsCameraPosition = ((Map<String, Object>) params.get("cameraPosition"));

    return new CameraPosition(
      Utils.pointFromJson(((Map<String, Object>) paramsCameraPosition.get("target"))),
      ((Double) paramsCameraPosition.get("zoom")).floatValue(),
      ((Double) paramsCameraPosition.get("azimuth")).floatValue(),
      ((Double) paramsCameraPosition.get("tilt")).floatValue()
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public CameraPosition newBounds(Map<String, Object> params) {
    if ((Map<String, Object>) params.get("focusRect") != null) {
      return mapView.getMap().cameraPosition(
        Utils.boundingBoxFromJson((Map<String, Object>) params.get("boundingBox")),
        Utils.screenRectFromJson((Map<String, Object>) params.get("focusRect"))
      );
    }

    return mapView.getMap().cameraPosition(
      Utils.boundingBoxFromJson((Map<String, Object>) params.get("boundingBox"))
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public CameraPosition newTiltAzimuthGeometry(Map<String, Object> params) {
    ScreenRect focus = (Map<String, Object>) params.get("focusRect") != null ?
      Utils.screenRectFromJson((Map<String, Object>) params.get("focusRect")) :
      null;

    return mapView.getMap().cameraPosition(
      Utils.geometryFromJson((Map<String, Object>) params.get("geometry")),
      ((Double) params.get("azimuth")).floatValue(),
      ((Double) params.get("tilt")).floatValue(),
      focus
    );
  }

  private CameraPosition zoomIn() {
    CameraPosition curPosition = mapView.getMap().getCameraPosition();

    return new CameraPosition(
      curPosition.getTarget(),
      curPosition.getZoom() + 1,
      curPosition.getAzimuth(),
      curPosition.getTilt()
    );
  }

  private CameraPosition zoomOut() {
    CameraPosition curPosition = mapView.getMap().getCameraPosition();

    return new CameraPosition(
      curPosition.getTarget(),
      curPosition.getZoom() - 1,
      curPosition.getAzimuth(),
      curPosition.getTilt()
    );
  }

  @SuppressWarnings({"ConstantConditions"})
  public CameraPosition zoomTo(Map<String, Object> params) {
    CameraPosition curPosition = mapView.getMap().getCameraPosition();

    return new CameraPosition(
      curPosition.getTarget(),
      ((Double) params.get("zoom")).floatValue(),
      curPosition.getAzimuth(),
      curPosition.getTilt()
    );
  }

  @SuppressWarnings({"ConstantConditions"})
  public CameraPosition azimuthTo(Map<String, Object> params) {
    CameraPosition curPosition = mapView.getMap().getCameraPosition();

    return new CameraPosition(
      curPosition.getTarget(),
      curPosition.getZoom(),
      ((Double) params.get("azimuth")).floatValue(),
      curPosition.getTilt()
    );
  }

  @SuppressWarnings({"ConstantConditions"})
  public CameraPosition tiltTo(Map<String, Object> params) {
    CameraPosition curPosition = mapView.getMap().getCameraPosition();

    return new CameraPosition(
      curPosition.getTarget(),
      curPosition.getZoom(),
      curPosition.getAzimuth(),
      ((Double) params.get("tilt")).floatValue()
    );
  }

  private boolean validCameraPosition(CameraPosition cameraPosition) {
    return !((Float) cameraPosition.getZoom()).isNaN() &&
      !((Float) cameraPosition.getZoom()).isNaN() &&
      !((Float) cameraPosition.getAzimuth()).isNaN() &&
      !((Double) cameraPosition.getTarget().getLatitude()).isNaN() &&
      !((Double) cameraPosition.getTarget().getLongitude()).isNaN();
  }

  @SuppressWarnings({"ConstantConditions"})
  private void move(
    CameraPosition cameraPosition,
    Map<String, Object> paramsAnimation,
    final MethodChannel.Result result
  ) {
    if (!validCameraPosition(cameraPosition)) {
      result.success(false);

      return;
    }

    if (paramsAnimation == null) {
      mapView.getMap().move(cameraPosition);
      result.success(true);

      return;
    }

    Animation.Type type = Animation.Type.values()[(Integer) paramsAnimation.get("type")];
    Animation animation = new Animation(type, ((Double) paramsAnimation.get("duration")).floatValue());

    mapView.getMap().move(
      cameraPosition,
      animation,
      new com.yandex.mapkit.map.Map.CameraCallback() {
        @Override
        public void onMoveFinished(boolean completed) {
          result.success(completed);
        }
      }
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void applyMapOptions(Map<String, Object> params) {
    com.yandex.mapkit.map.Map map = mapView.getMap();

    if (params.get("tiltGesturesEnabled") != null) {
      map.setTiltGesturesEnabled((Boolean) params.get("tiltGesturesEnabled"));
    }

    if (params.get("zoomGesturesEnabled") != null) {
      map.setZoomGesturesEnabled((Boolean) params.get("zoomGesturesEnabled"));
    }

    if (params.get("rotateGesturesEnabled") != null) {
      map.setRotateGesturesEnabled((Boolean) params.get("rotateGesturesEnabled"));
    }

    if (params.get("nightModeEnabled") != null) {
      map.setNightModeEnabled((Boolean) params.get("nightModeEnabled"));
    }

    if (params.get("scrollGesturesEnabled") != null) {
      map.setScrollGesturesEnabled((Boolean) params.get("scrollGesturesEnabled"));
    }

    if (params.get("fastTapEnabled") != null) {
      map.setFastTapEnabled((Boolean) params.get("fastTapEnabled"));
    }

    if (params.get("mode2DEnabled") != null) {
      map.set2DMode((Boolean) params.get("mode2DEnabled"));
    }

    if (params.get("modelsEnabled") != null) {
      map.setModelsEnabled((Boolean) params.get("modelsEnabled"));
    }

    if (params.get("logoAlignment") != null) {
      applyAlignLogo((Map<String, Object>) params.get("logoAlignment"));
    }

    if (params.containsKey("focusRect")) {
      applyFocusRect((Map<String, Object>) params.get("focusRect"));
    }

    if (params.get("mapType") != null) {
      map.setMapType(MapType.values()[(Integer) params.get("mapType")]);
    }

    if (params.containsKey("poiLimit")) {
      map.setPoiLimit((Integer) params.get("poiLimit"));
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void applyMapObjects(Map<String, Object> params) {
    List<Map<String, Object>> toChangeParams = (List<Map<String, Object>>) params.get("toChange");

    for (Map<String, Object> toChangeParam : toChangeParams) {
      if (toChangeParam.get("id").equals(rootController.id)) {
        rootController.update(toChangeParam);
      }
    }
  }

  @SuppressWarnings({"ConstantConditions"})
  private void applyAlignLogo(Map<String, Object> params) {
    Alignment logoPosition = new Alignment(
      HorizontalAlignment.values()[(Integer) params.get("horizontal")],
      VerticalAlignment.values()[(Integer) params.get("vertical")]
    );
    mapView.getMap().getLogo().setAlignment(logoPosition);
  }

  private void applyFocusRect(Map<String, Object> params) {
    if (params == null) {
      mapView.setFocusRect(null);
      mapView.setPointOfView(PointOfView.SCREEN_CENTER);

      return;
    }

    ScreenRect focusRect = Utils.screenRectFromJson(params);

    if (
      focusRect.getTopLeft().getY() < 0 ||
      focusRect.getTopLeft().getX() < 0 ||
      focusRect.getBottomRight().getY() > mapView.getMapWindow().height() ||
      focusRect.getBottomRight().getX() > mapView.getMapWindow().width()
    ) {
      return;
    }

    mapView.setFocusRect(focusRect);
    mapView.setPointOfView(PointOfView.ADAPT_TO_FOCUS_POINT_HORIZONTALLY);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void onObjectAdded(final UserLocationView view) {
    final YandexMapController self = this;
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("pinPoint", Utils.pointToJson(view.getPin().getGeometry()));
    arguments.put("arrowPoint", Utils.pointToJson(view.getArrow().getGeometry()));
    arguments.put("circle", Utils.circleToJson(view.getAccuracyCircle().getGeometry()));

    methodChannel.invokeMethod("onUserLocationAdded", arguments, new MethodChannel.Result() {
      @Override
      public void success(@Nullable Object result) {
        if (result instanceof FlutterException) {
          return;
        }

        Map<String, Object> params = ((Map<String, Object>) result);

        userPinController = new PlacemarkMapObjectController(
          view.getPin(),
          (Map<String, Object>) params.get("pin"),
          new WeakReference<>(self)
        );

        userArrowController = new PlacemarkMapObjectController(
          view.getArrow(),
          (Map<String, Object>) params.get("arrow"),
          new WeakReference<>(self)
        );

        userAccuracyCircleController = new CircleMapObjectController(
          view.getAccuracyCircle(),
          (Map<String, Object>) params.get("accuracyCircle"),
          new WeakReference<>(self)
        );
      }

      @Override
      public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {}
      @Override
      public void notImplemented() {}
    });
  }

  public void onObjectRemoved(@NonNull UserLocationView view) {}

  public void onObjectUpdated(@NonNull UserLocationView view, @NonNull ObjectEvent event) {}

  public void onTrafficChanged(@Nullable TrafficLevel trafficLevel) {
    Map<String, Object> arguments = new HashMap<>();
    Map<String, Object> trafficLevelMap = new HashMap<>();

    if (trafficLevel != null) {
      trafficLevelMap.put("level", trafficLevel.getLevel());
      trafficLevelMap.put("color", trafficLevel.getColor().ordinal());
    }

    arguments.put("trafficLevel", trafficLevelMap);

    methodChannel.invokeMethod("onTrafficChanged", arguments);
  }

  public void onTrafficLoading() {}

  public void onTrafficExpired() {}

  public void onCameraPositionChanged(
    @NonNull com.yandex.mapkit.map.Map map,
    @NonNull CameraPosition cameraPosition,
    @NonNull CameraUpdateReason cameraUpdateReason,
    boolean finished
  ) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("cameraPosition", Utils.cameraPositionToJson(cameraPosition));
    arguments.put("reason", cameraUpdateReason.ordinal());
    arguments.put("finished", finished);

    methodChannel.invokeMethod("onCameraPositionChanged", arguments);
  }

  public void onMapTap(@NonNull com.yandex.mapkit.map.Map map, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("point", Utils.pointToJson(point));

    methodChannel.invokeMethod("onMapTap", arguments);
  }

  public void onMapLongTap(@NonNull com.yandex.mapkit.map.Map map, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("point", Utils.pointToJson(point));

    methodChannel.invokeMethod("onMapLongTap", arguments);
  }

  public boolean onObjectTap(@NonNull GeoObjectTapEvent geoObjectTapEvent) {
    GeoObject geoObj = geoObjectTapEvent.getGeoObject();
    GeoObjectSelectionMetadata meta = geoObj.getMetadataContainer().getItem(GeoObjectSelectionMetadata.class);
    Map<String, Object> arguments = new HashMap<>();
    Map<String, Object> geoObjMap = new HashMap<>();
    Map<String, Object> metaMap = new HashMap<>();
    List<Map<String, Object>> geometryList = new ArrayList<>();

    for (Geometry geometry: geoObj.getGeometry()) {
      geometryList.add(Utils.geometryToJson(geometry));
    }

    if (meta != null) {
      metaMap.put("id", meta.getId());
      metaMap.put("layerId", meta.getLayerId());
    }

    geoObjMap.put("name", geoObj.getName());
    geoObjMap.put("descriptionText", geoObj.getDescriptionText());
    geoObjMap.put("geometry", geometryList);
    geoObjMap.put(
      "boundingBox",
      geoObj.getBoundingBox() == null ? null : Utils.boundingBoxToJson(geoObj.getBoundingBox())
    );
    geoObjMap.put("selectionMetadata", metaMap);
    geoObjMap.put("aref", geoObj.getAref());

    arguments.put("geoObject", geoObjMap);

    methodChannel.invokeMethod("onObjectTap", arguments);

    return false;
  }

  public void mapObjectDragStart(@NonNull String id) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);

    methodChannel.invokeMethod("onMapObjectDragStart", arguments);
  }

  public void mapObjectDrag(@NonNull String id, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("point", Utils.pointToJson(point));

    methodChannel.invokeMethod("onMapObjectDrag", arguments);
  }

  public void mapObjectDragEnd(@NonNull String id) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);

    methodChannel.invokeMethod("onMapObjectDragEnd", arguments);
  }

  public void mapObjectTap(@NonNull String id, @NonNull Point point) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("point", Utils.pointToJson(point));

    methodChannel.invokeMethod("onMapObjectTap", arguments);
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
  }

  @Override
  public void onLayoutChange(View view, int i, int i1, int i2, int i3, int i4, int i5, int i6, int i7) {
    if (initResult != null) {
      initResult.success(null);
      initResult = null;
    }
  }
}
