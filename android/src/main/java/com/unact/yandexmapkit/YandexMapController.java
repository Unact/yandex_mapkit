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
import com.yandex.mapkit.MapKitFactory;
import com.yandex.mapkit.ScreenPoint;
import com.yandex.mapkit.ScreenRect;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.layers.ObjectEvent;
import com.yandex.mapkit.logo.Alignment;
import com.yandex.mapkit.logo.HorizontalAlignment;
import com.yandex.mapkit.logo.VerticalAlignment;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.InputListener;
import com.yandex.mapkit.map.MapWindow;
import com.yandex.mapkit.map.PointOfView;
import com.yandex.mapkit.map.CameraUpdateReason;
import com.yandex.mapkit.map.CameraListener;
import com.yandex.mapkit.map.VisibleRegion;
import com.yandex.mapkit.map.SizeChangedListener;
import com.yandex.mapkit.mapview.MapView;
import com.yandex.mapkit.user_location.UserLocationLayer;
import com.yandex.mapkit.user_location.UserLocationObjectListener;
import com.yandex.mapkit.user_location.UserLocationView;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class YandexMapController implements
  PlatformView,
  MethodChannel.MethodCallHandler,
  DefaultLifecycleObserver,
  UserLocationObjectListener,
  InputListener,
  SizeChangedListener,
  CameraListener
{
  private final MapView mapView;
  public final Context context;
  public final MethodChannel methodChannel;
  private final YandexMapkitPlugin.LifecycleProvider lifecycleProvider;
  private final UserLocationLayer userLocationLayer;
  private YandexPlacemarkController userPinController;
  private YandexPlacemarkController userArrowController;
  private YandexCircleController userAccuracyCircleController;
  private final YandexMapObjectCollectionController rootController;
  private boolean disposed = false;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public YandexMapController(
    int id,
    Context context,
    BinaryMessenger messenger,
    Map<String, Object> params,
    YandexMapkitPlugin.LifecycleProvider lifecycleProvider
  ) {
    this.lifecycleProvider = lifecycleProvider;
    this.context = context;
    mapView = new MapView(context);
    mapView.onStart();

    userLocationLayer = MapKitFactory.getInstance().createUserLocationLayer(mapView.getMapWindow());

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_map_" + id);
    methodChannel.setMethodCallHandler(this);

    rootController = new YandexMapObjectCollectionController(
      mapView.getMap().getMapObjects(),
      "root_map_object_collection",
      new WeakReference<>(this)
    );

    mapView.getMap().addInputListener(this);
    mapView.getMap().addCameraListener(this);
    mapView.getMapWindow().addSizeChangedListener(this);

    lifecycleProvider.getLifecycle().addObserver(this);
    userLocationLayer.setObjectListener(this);

    applyMapOptions((Map<String, Object>) params.get("mapOptions"));
    applyMapObjects((Map<String, Object>) params.get("mapObjects"));
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

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void setFocusRect(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsTopLeft = ((Map<String, Object>) params.get("topLeft"));
    Map<String, Object> paramsBottomRight = ((Map<String, Object>) params.get("bottomRight"));
    ScreenRect screenRect = new ScreenRect(
      Utils.screenPointFromJson(paramsTopLeft),
      Utils.screenPointFromJson(paramsBottomRight)
    );

    mapView.setFocusRect(screenRect);
    mapView.setPointOfView(PointOfView.ADAPT_TO_FOCUS_RECT_HORIZONTALLY);
  }

  public void clearFocusRect() {
    mapView.setFocusRect(null);
    mapView.setPointOfView(PointOfView.SCREEN_CENTER);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void logoAlignment(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Alignment logoPosition = new Alignment(
      HorizontalAlignment.values()[(Integer) params.get("horizontal")],
      VerticalAlignment.values()[(Integer) params.get("vertical")]
    );
    mapView.getMap().getLogo().setAlignment(logoPosition);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void toggleUserLayer(MethodCall call) {
    if (!hasLocationPermission()) return;

    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    userLocationLayer.setVisible((Boolean) params.get("visible"));
    userLocationLayer.setHeadingEnabled((Boolean) params.get("headingEnabled"));
    userLocationLayer.setAutoZoomEnabled((Boolean) params.get("autoZoomEnabled"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void setMapStyle(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    mapView.getMap().setMapStyle((String) params.get("style"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void move(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsAnimation = ((Map<String, Object>) params.get("animation"));
    Map<String, Object> paramsCameraPosition = ((Map<String, Object>) params.get("cameraPosition"));
    Map<String, Object> paramsTarget = ((Map<String, Object>) paramsCameraPosition.get("target"));
    CameraPosition cameraPosition = new CameraPosition(
      Utils.pointFromJson(paramsTarget),
      ((Double) paramsCameraPosition.get("zoom")).floatValue(),
      ((Double) paramsCameraPosition.get("azimuth")).floatValue(),
      ((Double) paramsCameraPosition.get("tilt")).floatValue()
    );

    moveWithParams(paramsAnimation, cameraPosition);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void setBounds(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    Map<String, Object> paramsAnimation = ((Map<String, Object>) params.get("animation"));
    Map<String, Object> paramsBoundingBox = (Map<String, Object>) params.get("boundingBox");
    Map<String, Object> southWest = (Map<String, Object>) paramsBoundingBox.get("southWest");
    Map<String, Object> northEast = (Map<String, Object>) paramsBoundingBox.get("northEast");
    CameraPosition cameraPosition = mapView.getMap().cameraPosition(new BoundingBox(
        Utils.pointFromJson(southWest),
        Utils.pointFromJson(northEast)
      )
    );

    moveWithParams(paramsAnimation, cameraPosition);
  }

  public Map<String, Double> getPoint(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Point point = mapView.getMapWindow().screenToWorld(Utils.screenPointFromJson(params));

    if (point != null) {
      return Utils.pointToJson(point);
    }

    return null;
  }

  public Map<String, Float> getScreenPoint(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    ScreenPoint screenPoint = mapView.getMapWindow().worldToScreen(Utils.pointFromJson(params));

    if (screenPoint != null) {
      return Utils.screenPointToJson(screenPoint);
    }

    return null;
  }

  public Map<String, Object> getCameraPosition() {
    Map<String, Object> arguments = new HashMap<>();

    arguments.put("cameraPosition", Utils.cameraPositionToJson(mapView.getMapWindow().getMap().getCameraPosition()));

    return arguments;
  }

  public Map<String, Object> getVisibleRegion() {
    VisibleRegion region = mapView.getMap().getVisibleRegion();

    Map<String, Object> visibleRegionArguments = new HashMap<>();
    visibleRegionArguments.put("bottomLeft", Utils.pointToJson(region.getBottomLeft()));
    visibleRegionArguments.put("bottomRight", Utils.pointToJson(region.getBottomRight()));
    visibleRegionArguments.put("topLeft", Utils.pointToJson(region.getTopLeft()));
    visibleRegionArguments.put("topRight", Utils.pointToJson(region.getTopRight()));

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("visibleRegion", visibleRegionArguments);

    return arguments;
  }

  public Map<String, Object> getFocusRegion() {
    VisibleRegion region = mapView.getMapWindow().getFocusRegion();

    Map<String, Object> visibleRegionArguments = new HashMap<>();
    visibleRegionArguments.put("bottomLeft", Utils.pointToJson(region.getBottomLeft()));
    visibleRegionArguments.put("bottomRight", Utils.pointToJson(region.getBottomRight()));
    visibleRegionArguments.put("topLeft", Utils.pointToJson(region.getTopLeft()));
    visibleRegionArguments.put("topRight", Utils.pointToJson(region.getTopRight()));

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("focusRegion", visibleRegionArguments);

    return arguments;
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void updateMapObjects(MethodCall call) {
    Map<String, Object> params = (Map<String, Object>) call.arguments;

    applyMapObjects(params);
  }

  public void updateMapOptions(MethodCall call) {
    Map<String, Object> params = (Map<String, Object>) call.arguments;

    applyMapOptions(params);
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

  public void zoomIn() {
    zoom(1f);
  }

  public void zoomOut() {
    zoom(-1f);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void applyMapOptions(Map<String, Object> params) {
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

    if (params.get("indoorEnabled") != null) {
      map.setIndoorEnabled((Boolean) params.get("indoorEnabled"));
    }

    if (params.get("liteModeEnabled") != null) {
      map.setLiteModeEnabled((Boolean) params.get("liteModeEnabled"));
    }

    if (params.get("modelsEnabled") != null) {
      map.setModelsEnabled((Boolean) params.get("modelsEnabled"));
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void applyMapObjects(Map<String, Object> params) {
    List<Map<String, Object>> toChangeParams = (List<Map<String, Object>>) params.get("toChange");

    for (Map<String, Object> toChangeParam : toChangeParams) {
      if (toChangeParam.get("id").equals(rootController.id)) {
        rootController.update(toChangeParam);
      }
    }
  }

  public float getMinZoom() {
    return mapView.getMap().getMinZoom();
  }

  public float getMaxZoom() {
    return mapView.getMap().getMaxZoom();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "waitForInit":
        result.success(null);
        break;
      case "logoAlignment":
        logoAlignment(call);
        result.success(null);
        break;
      case "toggleUserLayer":
        toggleUserLayer(call);
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
      case "updateMapObjects":
        updateMapObjects(call);
        result.success(null);
        break;
      case "updateMapOptions":
        updateMapOptions(call);
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
      context,
      Manifest.permission.ACCESS_FINE_LOCATION
    );
    return permissionState == PackageManager.PERMISSION_GRANTED;
  }

  @SuppressWarnings({"ConstantConditions"})
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

  public void onObjectAdded(final UserLocationView view) {
    final YandexMapController self = this;
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("pinPoint", Utils.pointToJson(view.getPin().getGeometry()));
    arguments.put("arrowPoint", Utils.pointToJson(view.getArrow().getGeometry()));
    arguments.put("circle", Utils.circleToJson(view.getAccuracyCircle().getGeometry()));

    methodChannel.invokeMethod("onUserLocationAdded", arguments, new MethodChannel.Result() {
      @Override
      public void success(@Nullable Object result) {
        Map<String, Object> params = ((Map<String, Object>) result);

        if (!view.isValid()) {
          return;
        }

        userPinController = new YandexPlacemarkController(
          view.getPin().getParent(),
          view.getPin(),
          (Map<String, Object>) params.get("pin"),
          new WeakReference<>(self)
        );

        userArrowController = new YandexPlacemarkController(
          view.getArrow().getParent(),
          view.getArrow(),
          (Map<String, Object>) params.get("arrow"),
          new WeakReference<>(self)
        );

        userAccuracyCircleController = new YandexCircleController(
          view.getAccuracyCircle(),
          (Map<String, Object>) params.get("accuracyCircle"),
          new WeakReference<>(self)
        );
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {}
      @Override
      public void notImplemented() {}
    });
  }

  public void onObjectRemoved(@NonNull UserLocationView view) {}

  public void onObjectUpdated(@NonNull UserLocationView view, @NonNull ObjectEvent event) {}

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

  public void onMapWindowSizeChanged(@NonNull MapWindow mapWindow, int newWidth, int newHeight) {
    Map<String, Object> mapSizeArguments = new HashMap<>();
    mapSizeArguments.put("width", newWidth);
    mapSizeArguments.put("height", newHeight);

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("mapSize", mapSizeArguments);

    methodChannel.invokeMethod("onMapSizeChanged", arguments);
  }
}
