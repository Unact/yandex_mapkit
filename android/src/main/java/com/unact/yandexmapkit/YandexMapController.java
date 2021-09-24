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
import com.yandex.mapkit.map.Cluster;
import com.yandex.mapkit.map.ClusterListener;
import com.yandex.mapkit.map.ClusterTapListener;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
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
  private YandexClusterListener yandexClusterListener;
  private YandexClusterTapListener yandexClusterTapListener;

  private List<MapObjectCollection>             collections            = new ArrayList<>();
  private List<ClusterizedPlacemarkCollection>  clusterizedCollections = new ArrayList<>();

  private UserLocationLayer userLocationLayer;

  private PlacemarkMapObject cameraTarget = null;

  private List<PlacemarkMapObject> placemarks = new ArrayList<>();
  private List<PolylineMapObject> polylines = new ArrayList<>();
  private List<PolygonMapObject> polygons = new ArrayList<>();
  private List<CircleMapObject> circles = new ArrayList<>();

  // Use this as workaround for mapkit issue which leads to unavailability of getting a placemark's collection
  // (method getParent() throws exception for placemarks in ClusterizedPlacemarkCollection)
  // https://github.com/yandex/mapkit-android-demo/issues/258
  private HashMap<Integer, ArrayList<PlacemarkMapObject>> placemarksByCollections = new HashMap<>();

  private List<Cluster> unstyledClustersQueue = new ArrayList<>();

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
    Map<String, Object> paramsBoundingBox = (Map<String, Object>) params.get("boundingBox");
    Map<String, Object> southWest = (Map<String, Object>) paramsBoundingBox.get("southWest");
    Map<String, Object> northEast = (Map<String, Object>) paramsBoundingBox.get("northEast");
    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) southWest.get("latitude")), ((Double) southWest.get("longitude"))),
      new Point(((Double) northEast.get("latitude")), ((Double) northEast.get("longitude")))
    );

    moveWithParams(params, mapView.getMap().cameraPosition(boundingBox));
  }

  public void addCollection(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Integer id            = (Integer) params.get("id");
    Integer parentId      = (Integer) params.get("parentId");
    boolean isClusterized = params.get("isClusterized") != null ? (Boolean) params.get("isClusterized") : false;

    MapObject parent = getCollectionById(parentId);

    // Only plain (YMKMapObjectCollection) can be nested,YMKClusterizedPlacemarkCollection - can not
    if (!(parent instanceof MapObjectCollection)) {
      return;
    }

    MapObjectCollection parentCollection = (MapObjectCollection) parent;

    if (!isClusterized) {
      MapObjectCollection collection = parentCollection.addCollection();
      collection.setUserData(id);
      collections.add(collection);
    } else {
      if (yandexClusterListener == null) {
        yandexClusterListener = new YandexClusterListener();
      }
      ClusterizedPlacemarkCollection collection = parentCollection.addClusterizedPlacemarkCollection(yandexClusterListener);
      collection.setUserData(id);
      clusterizedCollections.add(collection);
    }

    placemarksByCollections.put(id, new ArrayList<PlacemarkMapObject>());
  }

  private MapObject getCollectionById(Integer collectionId) {

    if (collectionId == null) {
      return mapView.getMapWindow().getMap().getMapObjects();
    }

    for (int i = 0; i < collections.size(); i++) {
      if (collections.get(i).getUserData().equals(collectionId)) {
        return collections.get(i);
      }
    }

    for (int i = 0; i < clusterizedCollections.size(); i++) {
      if (clusterizedCollections.get(i).getUserData().equals(collectionId)) {
        return clusterizedCollections.get(i);
      }
    }

    return null;
  }

  @SuppressWarnings("unchecked")
  public void addPlacemark(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Integer collectionId = (Integer) params.get("collectionId");

    Map<String, Object> paramsPoint = ((Map<String, Object>) params.get("point"));

    Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));

    PlacemarkMapObject placemark;

    MapObject collection = getCollectionById(collectionId);

    if (collection instanceof MapObjectCollection) {
      placemark = ((MapObjectCollection) collection).addPlacemark(point);
    } else if (collection instanceof ClusterizedPlacemarkCollection) {
      placemark = ((ClusterizedPlacemarkCollection) collection).addPlacemark(point);
    } else {
      return;
    }

    placemark.addTapListener(yandexMapObjectTapListener);
    setupPlacemark(placemark, params);

    placemarks.add(placemark);

    if (collectionId != null) {
      ArrayList<PlacemarkMapObject> collectionPlacemarks = placemarksByCollections.get(collectionId);
      collectionPlacemarks.add(placemark);
      placemarksByCollections.put(collectionId, collectionPlacemarks);
    }
  }

  public void addPlacemarks(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Integer collectionId = (Integer) params.get("collectionId");

    if (params.get("points") == null || params.get("ids") == null || params.get("icon") == null) {
      return;
    }

    List<Map<String, Object>> points  = ((List<Map<String, Object>>) params.get("points"));
    List<Object>              ids     = ((List<Object>) params.get("ids"));
    Map<String, Object>       icon    = ((Map<String, Object>) params.get("icon"));

    List<Point> mapkitPoints = new ArrayList<>();

    for (int i = 0; i < points.size(); i++) {

      Map<String, Object> p = points.get(i);

      Point point = new Point((Double) p.get("latitude"), (Double) p.get("longitude"));

      mapkitPoints.add(point);
    }

    ImageProvider img = getIconImage(icon);

    if (img == null) {
      return;
    }

    IconStyle iconStyle = new IconStyle();

    if (icon.get("style") != null) {
      iconStyle = getIconStyle(icon);
    }

    List<PlacemarkMapObject> newPlacemarks;

    MapObject collection = getCollectionById(collectionId);

    if (collection instanceof MapObjectCollection) {
      newPlacemarks = ((MapObjectCollection) collection).addPlacemarks(mapkitPoints, img, iconStyle);
    } else if (collection instanceof ClusterizedPlacemarkCollection) {
      newPlacemarks = ((ClusterizedPlacemarkCollection) collection).addPlacemarks(mapkitPoints, img, iconStyle);
    } else {
      return;
    }

    for (int i = 0; i < newPlacemarks.size(); i++) {

      PlacemarkMapObject p = newPlacemarks.get(i);

      p.setUserData(ids.get(i));
      p.addTapListener(yandexMapObjectTapListener);
    }

    placemarks.addAll(newPlacemarks);

    if (collectionId != null) {
      ArrayList<PlacemarkMapObject> collectionPlacemarks = placemarksByCollections.get(collectionId);
      collectionPlacemarks.addAll(newPlacemarks);
      placemarksByCollections.put(collectionId, collectionPlacemarks);
    }
  }

  @SuppressWarnings("unchecked")
  public void removePlacemark(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Integer id = (Integer) params.get("id");

    PlacemarkMapObject placemark = null;

    for (int i = 0; i < placemarks.size(); i++) {
      if (placemarks.get(i).getUserData().equals(id)) {
        placemark = placemarks.get(i);
        break;
      }
    }

    if (placemark == null) {
      return;
    }

    // Use this as workaround for mapkit issue which leads to unavailability of getting a placemark's collection
    // (method getParent() throws exception for placemarks in ClusterizedPlacemarkCollection)
    // https://github.com/yandex/mapkit-android-demo/issues/258
    Integer parentId = null;
    Iterator iterator = placemarksByCollections.entrySet().iterator();
    while (iterator.hasNext()) {
      Map.Entry pair = (Map.Entry)iterator.next();
      if (placemarksByCollections.get(pair.getKey()).contains(placemark)) {
        parentId = (Integer) pair.getKey();
      }
    }

    MapObject collection = getCollectionById(parentId);

    if (collection instanceof MapObjectCollection) {
      ((MapObjectCollection) collection).remove(placemark);
    } else if (collection instanceof ClusterizedPlacemarkCollection) {
      ((ClusterizedPlacemarkCollection) collection).remove(placemark);
    } else {
      return;
    }

    // Remove from local list
    placemarks.remove(placemark);
  }

  public void clear(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Integer collectionId = (Integer) params.get("collectionId");

    MapObject collection = getCollectionById(collectionId);

    if (collection instanceof MapObjectCollection) {

      if (collectionId == null) {

        collections.clear();
        clusterizedCollections.clear();

        placemarks.clear();
        polylines.clear();
        polygons.clear();
        circles.clear();

      } else {

        List<Integer> nestedCollectionsIds = new ArrayList<>();
        nestedCollectionsIds.add(collectionId);

        // Get all plain (not clusterized) nested collections ids using recursive func
        nestedCollectionsIds = getNestedCollectionsIds(nestedCollectionsIds);

        // Add all clusterized placemark collections nested in plain collections (no recursion is needed because clusterized collections can't be nested itself)
        for (int i = 0; i < clusterizedCollections.size(); i++) {

          ClusterizedPlacemarkCollection coll = clusterizedCollections.get(i);

          Integer parentId = (Integer) coll.getParent().getUserData();

          if (parentId == null) {
            continue;
          }

          if (nestedCollectionsIds.contains(parentId)) {
            nestedCollectionsIds.add((Integer) coll.getUserData());
          }
        }

        // Remove all placemarks which parents are in the nestedCollectionsIds list
        for (int i = 0; i < nestedCollectionsIds.size(); i++) {
          placemarks.removeAll(placemarksByCollections.get(nestedCollectionsIds.get(i)));
          placemarksByCollections.get(nestedCollectionsIds.get(i)).clear();
        }

        // Remove all nested collections except current one

        List<MapObjectCollection> collectionsToRemove = new ArrayList<>();
        for (int i = 0; i < collections.size(); i++) {
          if (nestedCollectionsIds.contains(collections.get(i).getUserData()) && !collections.get(i).getUserData().equals(collectionId)) {
            collectionsToRemove.add(collections.get(i));
            placemarksByCollections.remove(collections.get(i).getUserData());
          }
        }
        collections.removeAll(collectionsToRemove);

        List<ClusterizedPlacemarkCollection> clusterizedCollectionsToRemove = new ArrayList<>();
        for (int i = 0; i < clusterizedCollections.size(); i++) {
          if (nestedCollectionsIds.contains(clusterizedCollections.get(i).getUserData()) && !clusterizedCollections.get(i).getUserData().equals(collectionId)) {
            clusterizedCollectionsToRemove.add(clusterizedCollections.get(i));
            placemarksByCollections.remove(clusterizedCollections.get(i).getUserData());
          }
        }
        clusterizedCollections.removeAll(clusterizedCollectionsToRemove);

        /*
        TODO: For now polylines, polygons and circles can be added only into the root collection (mapObjects),
         so there is no need to clear corresponding arrays, but should be implemented if addPolyline, addPolygon or addCircle
         will become to accept collectionId argument.
        */
      }

      // Clear mapkit collection
      ((MapObjectCollection) collection).clear();

    } else if (collection instanceof ClusterizedPlacemarkCollection) {

      // As clusterized collections can not be nested just remove all placemarks with parent = collectionId
      placemarks.removeAll(placemarksByCollections.get(collectionId));
      placemarksByCollections.get(collectionId).clear();

      // Clear mapkit collection
      ((ClusterizedPlacemarkCollection) collection).clear();
    }
  }

  private List<Integer> getNestedCollectionsIds(List<Integer> nestedIds) {

    List<Integer> ids = nestedIds;

    for (int i = 0; i < collections.size(); i++) {

      MapObjectCollection coll = collections.get(i);

      Integer id        = (Integer) coll.getUserData();
      Integer parentId  = (Integer) coll.getParent().getUserData();

      if (id == null || parentId == null) {
        continue;
      }

      if (ids.contains(parentId) && !ids.contains(id)) {
        ids.add(id);
        return getNestedCollectionsIds(ids);
      }
    }

    return ids;
  }

  public void clusterPlacemarks(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    Integer collectionId = (Integer) params.get("collectionId");

    if (collectionId == null ||params.get("clusterRadius") == null || params.get("minZoom") == null) {
      return;
    }

    MapObject collection = getCollectionById(collectionId);
    if (!(collection instanceof ClusterizedPlacemarkCollection)) {
      return;
    }

    Double clusterRadius = (Double) params.get("clusterRadius");
    Integer minZoom      = (Integer) params.get("minZoom");

    ((ClusterizedPlacemarkCollection) collection).clusterPlacemarks(clusterRadius, minZoom);
  }

  /// Finds cluster by hashValue in the unstyledClustersQueue and sets icon.
  /// Can be called only once on a single cluster - cluster removes from queue after it is handled.
  public void setClusterIcon(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    if (params.get("hashValue") == null) {
      return;
    }

    int hashValue = (int) params.get("hashValue");

    Cluster foundCluster      = null;
    int     foundClusterIndex = -1;

    for (int i = 0; i < unstyledClustersQueue.size(); i++) {
      if (unstyledClustersQueue.get(i).hashCode() == hashValue) {
        foundCluster = unstyledClustersQueue.get(i);
        foundClusterIndex = i;
        break;
      }
    }

    if (foundCluster == null) {
      return;
    }

    if (params.get("icon") != null) {

      Map<String, Object> icon = ((Map<String, Object>) params.get("icon"));

      ImageProvider img = getIconImage(icon);

      // Check for isValid to prevent crashes when cluster is not already showing (sometimes may be caused by Flutter interaction delay)
      if (img != null && foundCluster.isValid()) {
        foundCluster.getAppearance().setIcon(img);
      }
    }

    unstyledClustersQueue.remove(foundClusterIndex);
  }

  private void setupPlacemark(PlacemarkMapObject placemark, Map<String, Object> params) {

    placemark.setUserData(params.get("id"));

    placemark.setOpacity(((Double) params.get("opacity")).floatValue());
    placemark.setDraggable((Boolean) params.get("isDraggable"));
    placemark.setDirection(((Double) params.get("direction")).floatValue());
    placemark.setDraggable((Boolean) params.get("isVisible"));

    if (params.get("zIndex") != null) {
      placemark.setZIndex((float) params.get("zIndex"));
    }

    Map<String, Object> icon = ((Map<String, Object>) params.get("icon"));
    Map<String, Object> composite = ((Map<String, Object>) params.get("composite"));

    if (icon != null) {

      ImageProvider img = getIconImage(icon);

      if (img != null) {
        placemark.setIcon(img);
      }

      Map<String, Object> iconStyle = ((Map<String, Object>) icon.get("style"));

      if (iconStyle != null) {
        IconStyle style = getIconStyle(iconStyle);
        placemark.setIconStyle(style);
      }

    } else if (composite != null) {

      for (Map.Entry<String, Object> entry : composite.entrySet()) {

        String name = entry.getKey();
        Map<String, Object> iconData = (Map<String, Object>) entry.getValue();

        if (name == null || iconData == null) {
          continue;
        }

        ImageProvider img = getIconImage(iconData);

        if (img == null) {
          continue;
        }

        IconStyle style = new IconStyle();

        Map<String, Object> iconStyle = ((Map<String, Object>) iconData.get("style"));

        if (iconStyle != null) {
          style = getIconStyle(iconStyle);
        }

        placemark.useCompositeIcon().setIcon(name, img, style);
      }
    }
  }

  private ImageProvider getIconImage(Map<String, Object> iconData) {

    ImageProvider img = null;

    String iconName = (String) iconData.get("iconName");
    byte[] rawImageData = (byte[]) iconData.get("rawImageData");

    if (iconName != null) {
      FlutterLoader loader = FlutterInjector.instance().flutterLoader();
      img = ImageProvider.fromAsset(mapView.getContext(), loader.getLookupKeyForAsset(iconName));
    }

    if (rawImageData != null) {
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
        ((Double) anchor.get("x")).floatValue(),
        ((Double) anchor.get("y")).floatValue()
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

    MapObjectCollection mapObjects = mapView.getMap().getMapObjects();

    if (cameraTarget != null) {
      mapObjects.remove(cameraTarget);
      cameraTarget = null;
    }

    Point targetPoint =  mapView.getMapWindow().getMap().getCameraPosition().getTarget();

    if (call.arguments != null) {

      Map<String, Object> params = ((Map<String, Object>) call.arguments);

      Map<String, Object> placemarkTemplate = ((Map<String, Object>) params.get("placemarkTemplate"));

      Map<String, Object> paramsPoint = ((Map<String, Object>) placemarkTemplate.get("point"));

      Point point = new Point(((Double) paramsPoint.get("latitude")), ((Double) paramsPoint.get("longitude")));

      PlacemarkMapObject placemark = mapObjects.addPlacemark(point);

      setupPlacemark(placemark, placemarkTemplate);
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
      case "addCollection":
        addCollection(call);
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
      case "clusterPlacemarks":
        clusterPlacemarks(call);
        result.success(null);
        break;
      case "setClusterIcon":
        setClusterIcon(call);
        result.success(null);
        break;
      case "removePlacemark":
        removePlacemark(call);
        result.success(null);
        break;
      case "clear":
        clear(call);
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

      return true;
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

  private class YandexClusterListener implements ClusterListener {

    public void onClusterAdded(final Cluster cluster) {

      unstyledClustersQueue.add(cluster);

      final List<Integer> placemarksHashes = new ArrayList<>();

      for (int i = 0; i < cluster.getPlacemarks().size(); i++) {

        PlacemarkMapObject p = cluster.getPlacemarks().get(i);

        placemarksHashes.add((Integer) p.getUserData());
      }

      Map<String, Object> arguments = new HashMap<String, Object>() {{
        put("hashValue", cluster.hashCode());
        put("size", cluster.getSize());
        put("appearance", new HashMap<String, Object>() {{
          put("opacity", cluster.getAppearance().getOpacity());
          put("direction", cluster.getAppearance().getDirection());
          put("zIndex", cluster.getAppearance().getZIndex());
          put("geometry", new HashMap<String, Object>() {{
            put("latitude", cluster.getAppearance().getGeometry().getLatitude());
            put("longitude", cluster.getAppearance().getGeometry().getLongitude());
          }});
        }});
        put("placemarks", placemarksHashes);
      }};

      methodChannel.invokeMethod("onClusterAdded", arguments);

      if (yandexClusterTapListener == null) {
        yandexClusterTapListener = new YandexClusterTapListener();
      }

      cluster.addClusterTapListener(yandexClusterTapListener);
    }
  }

  private class YandexClusterTapListener implements ClusterTapListener {

    public boolean onClusterTap(final Cluster cluster) {

      final List<Integer> placemarksHashes = new ArrayList<>();

      for (int i = 0; i < cluster.getPlacemarks().size(); i++) {

        PlacemarkMapObject p = cluster.getPlacemarks().get(i);

        placemarksHashes.add((Integer) p.getUserData());
      }

      Map<String, Object> arguments = new HashMap<String, Object>() {{
        put("hashValue", cluster.hashCode());
        put("size", cluster.getSize());
        put("appearance", new HashMap<String, Object>() {{
          put("opacity", cluster.getAppearance().getOpacity());
          put("direction", cluster.getAppearance().getDirection());
          put("zIndex", cluster.getAppearance().getZIndex());
          put("geometry", new HashMap<String, Object>() {{
            put("latitude", cluster.getAppearance().getGeometry().getLatitude());
            put("longitude", cluster.getAppearance().getGeometry().getLongitude());
          }});
        }});
        put("placemarks", placemarksHashes);
      }};

      methodChannel.invokeMethod("onClusterTap", arguments);

      return true;
    }
  }
}
