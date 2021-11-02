package com.unact.yandexmapkit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.view.View;

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
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.layers.ObjectEvent;
import com.yandex.mapkit.logo.Alignment;
import com.yandex.mapkit.logo.HorizontalAlignment;
import com.yandex.mapkit.logo.VerticalAlignment;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.InputListener;
import com.yandex.mapkit.map.MapWindow;
import com.yandex.mapkit.map.PointOfView;
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

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class YandexMapController implements PlatformView, MethodChannel.MethodCallHandler, DefaultLifecycleObserver {
  private final MapView mapView;
  public final Context context;
  public final MethodChannel methodChannel;
  private final YandexMapkitPlugin.LifecycleProvider lifecycleProvider;
  private final YandexUserLocationObjectListener yandexUserLocationObjectListener;
  private YandexCameraListener yandexCameraListener;
  private final UserLocationLayer userLocationLayer;
  private String userLocationIconName;
  private String userArrowIconName;
  private Boolean userArrowOrientation;
  private int accuracyCircleFillColor = 0;
  private final YandexMapObjectCollectionController rootController;
  private boolean disposed = false;

  @SuppressWarnings({"ConstantConditions"})
  public YandexMapController(int id, Context context, BinaryMessenger messenger, YandexMapkitPlugin.LifecycleProvider lifecycleProvider) {
    this.lifecycleProvider = lifecycleProvider;
    this.context = context;
    mapView = new MapView(context);
    mapView.onStart();

    userLocationLayer = MapKitFactory.getInstance().createUserLocationLayer(mapView.getMapWindow());
    yandexUserLocationObjectListener = new YandexUserLocationObjectListener();

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_map_" + id);
    methodChannel.setMethodCallHandler(this);

    rootController = new YandexMapObjectCollectionController(
      mapView.getMap().getMapObjects(),
      "root_map_object_collection",
      new WeakReference<>(this)
    );

    mapView.getMap().addInputListener(new YandexMapInputListener());
    mapView.getMapWindow().addSizeChangedListener(new YandexMapSizeChangedListener());

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

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void toggleNightMode(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMap().setNightModeEnabled((Boolean) params.get("enabled"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void toggleMapRotation(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    mapView.getMap().setRotateGesturesEnabled((Boolean) params.get("enabled"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
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
  
  public Map<String, Object> getTargetPoint() {
    Point point =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();
    Map<String, Object> arguments = new HashMap<>();

    arguments.put("point", Utils.pointToJson(point));

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

  public void disableCameraTracking() {
    if (yandexCameraListener != null) {
      mapView.getMap().removeCameraListener(yandexCameraListener);
      yandexCameraListener = null;
    }
  }

  public void enableCameraTracking() {
    if (yandexCameraListener == null) {
      yandexCameraListener = new YandexCameraListener();
      mapView.getMap().addCameraListener(yandexCameraListener);
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void updateMapObjects(MethodCall call) {
    Map<String, Object> params = (Map<String, Object>) call.arguments;
    List<Map<String, Object>> toChangeParams = (List<Map<String, Object>>) params.get("toChange");

    for (Map<String, Object> toChangeParam : toChangeParams) {
      if (toChangeParam.get("id").equals(rootController.id)) {
        rootController.update(toChangeParam);
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
        arguments.put("point", Utils.pointToJson(point));

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

  @SuppressWarnings({"unchecked", "ConstantConditions"})
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

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void toggleTiltGestures(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    boolean enabled = (Boolean) params.get("enabled");

    mapView.getMap().setTiltGesturesEnabled(enabled);
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
        enableCameraTracking();
        result.success(null);
        break;
      case "disableCameraTracking":
        disableCameraTracking();
        result.success(null);
        break;
      case "updateMapObjects":
        updateMapObjects(call);
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
  
  private class YandexCameraListener implements CameraListener {
    @Override
    public void onCameraPositionChanged(
      @NonNull com.yandex.mapkit.map.Map map,
      CameraPosition cameraPosition,
      @NonNull CameraUpdateReason cameraUpdateReason,
      boolean finished
    ) {
      Point targetPoint = cameraPosition.getTarget();

      Map<String, Object> cameraPositionArguments = new HashMap<>();
      cameraPositionArguments.put("target", Utils.pointToJson(targetPoint));
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
        ImageProvider.fromAsset(
          context,
          FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(userLocationIconName)
        )
      );
      view.getArrow().setIcon(
        ImageProvider.fromAsset(
          context,
          FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(userArrowIconName)
        )
      );
      if (userArrowOrientation) {
        view.getArrow().setIconStyle(new IconStyle().setRotationType(RotationType.ROTATE));
      }
      view.getAccuracyCircle().setFillColor(accuracyCircleFillColor);
    }

    public void onObjectRemoved(@NonNull UserLocationView view) {}

    public void onObjectUpdated(@NonNull UserLocationView view, @NonNull ObjectEvent event) {}
  }

  private class YandexMapInputListener implements InputListener {
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
  }

  private class YandexMapSizeChangedListener implements SizeChangedListener {
    public void onMapWindowSizeChanged(@NonNull MapWindow mapWindow, int newWidth, int newHeight) {
      Map<String, Object> mapSizeArguments = new HashMap<>();
      mapSizeArguments.put("width", newWidth);
      mapSizeArguments.put("height", newHeight);

      Map<String, Object> arguments = new HashMap<>();
      arguments.put("mapSize", mapSizeArguments);

      methodChannel.invokeMethod("onMapSizeChanged", arguments);
    }
  }
}
