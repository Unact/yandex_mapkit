package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MapObjectCollectionController extends MapObjectController implements MapObjectTapListener {
  private final Map<String, MapObjectCollectionController> mapObjectCollections = new HashMap<>();
  private final Map<String, ClusterizedPlacemarkCollectionController> clusterizedPlacemarkCollections =
    new HashMap<>();
  private final Map<String, CircleMapObjectController> circles = new HashMap<>();
  private final Map<String, PlacemarkMapObjectController> placemarks = new HashMap<>();
  private final Map<String, PolygonMapObjectController> polygons = new HashMap<>();
  private final Map<String, PolylineMapObjectController> polylines = new HashMap<>();
  public final MapObjectCollection mapObjectCollection;
  private boolean consumeTapEvents = false;
  private final WeakReference<YandexMapController> controller;
  public final String id;

  public MapObjectCollectionController(
    MapObjectCollection root,
    String id,
    WeakReference<YandexMapController> controller
  ) {
    this.mapObjectCollection = root;
    this.id = id;
    this.controller = controller;

    mapObjectCollection.setUserData(this.id);
    mapObjectCollection.addTapListener(this);
  }

  public MapObjectCollectionController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    MapObjectCollection mapObjectCollection = parent.addCollection();

    this.mapObjectCollection = mapObjectCollection;
    this.id = (String) params.get("id");
    this.controller = controller;

    mapObjectCollection.setUserData(this.id);
    mapObjectCollection.addTapListener(this);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    mapObjectCollection.setZIndex(((Double) params.get("zIndex")).floatValue());
    mapObjectCollection.setVisible((Boolean) params.get("isVisible"));
    updateMapObjects((Map<String, Object>) params.get("mapObjects"));

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
  }

  public void remove() {
    for (ClusterizedPlacemarkCollectionController colController : clusterizedPlacemarkCollections.values()) {
      colController.remove();
    }
    for (CircleMapObjectController circleController : circles.values()) {
      circleController.remove();
    }
    for (MapObjectCollectionController mapObjectCollectionController : mapObjectCollections.values()) {
      mapObjectCollectionController.remove();
    }
    for (PlacemarkMapObjectController placemarkController : placemarks.values()) {
      placemarkController.remove();
    }
    for (PolygonMapObjectController polygonController : polygons.values()) {
      polygonController.remove();
    }
    for (PolylineMapObjectController polylineController : polylines.values()) {
      polylineController.remove();
    }

    clusterizedPlacemarkCollections.clear();
    circles.clear();
    mapObjectCollections.clear();
    placemarks.clear();
    polygons.clear();
    polylines.clear();

    mapObjectCollection.getParent().remove(mapObjectCollection);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void updateMapObjects(Map<String, Object> params) {
    addMapObjects((List<Map<String, Object>>) params.get("toAdd"));
    changeMapObjects((List<Map<String, Object>>) params.get("toChange"));
    removeMapObjects((List<Map<String, Object>>) params.get("toRemove"));
  }

  @SuppressWarnings({"ConstantConditions"})
  private void addMapObjects(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      switch ((String) el.get("type")) {
        case "CircleMapObject":
          addCircle(el);
          break;
        case "MapObjectCollection":
          addMapObjectCollection(el);
          break;
        case "PlacemarkMapObject":
          addPlacemark(el);
          break;
        case "PolygonMapObject":
          addPolygon(el);
          break;
        case "PolylineMapObject":
          addPolyline(el);
          break;
        case "ClusterizedPlacemarkCollection":
          addClusterizedPlacemarkCollection(el);
          break;
        default:
          break;
      }
    }
  }

  @SuppressWarnings({"ConstantConditions"})
  private void changeMapObjects(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      switch ((String) el.get("type")) {
        case "CircleMapObject":
          changeCircle(el);
          break;
        case "MapObjectCollection":
          changeMapObjectCollection(el);
          break;
        case "PlacemarkMapObject":
          changePlacemark(el);
          break;
        case "PolygonMapObject":
          changePolygon(el);
          break;
        case "PolylineMapObject":
          changePolyline(el);
          break;
        case "ClusterizedPlacemarkCollection":
          changeClusterizedPlacemarkCollection(el);
          break;
        default:
          break;
      }
    }
  }

  @SuppressWarnings({"ConstantConditions"})
  private void removeMapObjects(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      switch ((String) el.get("type")) {
        case "CircleMapObject":
          removeCircle(el);
          break;
        case "MapObjectCollection":
          removeMapObjectCollection(el);
          break;
        case "PlacemarkMapObject":
          removePlacemark(el);
          break;
        case "PolygonMapObject":
          removePolygon(el);
          break;
        case "PolylineMapObject":
          removePolyline(el);
          break;
        case "ClusterizedPlacemarkCollection":
          removeClusterizedPlacemarkCollection(el);
          break;
        default:
          break;
      }
    }
  }

  private void addCircle(Map<String, Object> params) {
    CircleMapObjectController circleController = new CircleMapObjectController(
      mapObjectCollection,
      params,
      controller
    );

    circles.put(circleController.id, circleController);
  }

  private void changeCircle(Map<String, Object> params) {
    String id = (String) params.get("id");
    CircleMapObjectController circleController = circles.get(id);

    if (circleController != null) circleController.update(params);
  }

  private void removeCircle(Map<String, Object> params) {
    String id = (String) params.get("id");
    CircleMapObjectController circleController = circles.get(id);

    if (circleController != null) circleController.remove();
    circles.remove(id);
  }

  private void addMapObjectCollection(Map<String, Object> params) {
    MapObjectCollectionController mapObjectCollectionController = new MapObjectCollectionController(
      mapObjectCollection,
      params,
      controller
    );

    mapObjectCollections.put(mapObjectCollectionController.id, mapObjectCollectionController);
  }

  private void changeMapObjectCollection(Map<String, Object> params) {
    String id = (String) params.get("id");
    MapObjectCollectionController mapObjectCollectionController = mapObjectCollections.get(id);

    if (mapObjectCollectionController != null) mapObjectCollectionController.update(params);
  }

  private void removeMapObjectCollection(Map<String, Object> params) {
    String id = (String) params.get("id");
    MapObjectCollectionController mapObjectCollectionController = mapObjectCollections.get(id);

    if (mapObjectCollectionController != null) mapObjectCollectionController.remove();
    mapObjectCollections.remove(id);
  }

  private void addPlacemark(Map<String, Object> params) {
    PlacemarkMapObjectController placemarkController = new PlacemarkMapObjectController(
      mapObjectCollection,
      params,
      controller
    );

    placemarks.put(placemarkController.id, placemarkController);
  }

  private void changePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");
    PlacemarkMapObjectController placemarkController = placemarks.get(id);

    if (placemarkController != null) placemarkController.update(params);
  }

  private void removePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");
    PlacemarkMapObjectController placemarkController = placemarks.get(id);

    if (placemarkController != null) placemarkController.remove();
    placemarks.remove(id);
  }

  private void addPolygon(Map<String, Object> params) {
    PolygonMapObjectController polygonController = new PolygonMapObjectController(
      mapObjectCollection,
      params,
      controller
    );

    polygons.put(polygonController.id, polygonController);
  }

  private void changePolygon(Map<String, Object> params) {
    String id = (String) params.get("id");
    PolygonMapObjectController polygonController = polygons.get(id);

    if (polygonController != null) polygonController.update(params);
  }

  private void removePolygon(Map<String, Object> params) {
    String id = (String) params.get("id");
    PolygonMapObjectController polygonController = polygons.get(id);

    if (polygonController != null) polygonController.remove();
    polygons.remove(id);
  }

  private void addPolyline(Map<String, Object> params) {
    PolylineMapObjectController polylineController = new PolylineMapObjectController(
      mapObjectCollection,
      params,
      controller
    );

    polylines.put(polylineController.id, polylineController);
  }

  private void changePolyline(Map<String, Object> params) {
    String id = (String) params.get("id");
    PolylineMapObjectController polylineController = polylines.get(id);

    if (polylineController != null) polylineController.update(params);
  }

  private void removePolyline(Map<String, Object> params) {
    String id = (String) params.get("id");
    PolylineMapObjectController polylineController = polylines.get(id);

    if (polylineController != null) polylineController.remove();
    polylines.remove(id);
  }

  private void addClusterizedPlacemarkCollection(Map<String, Object> params) {
    ClusterizedPlacemarkCollectionController colController = new ClusterizedPlacemarkCollectionController(
      mapObjectCollection,
      params,
      controller
    );

    clusterizedPlacemarkCollections.put(colController.id, colController);
  }

  private void changeClusterizedPlacemarkCollection(Map<String, Object> params) {
    String id = (String) params.get("id");
    ClusterizedPlacemarkCollectionController colController = clusterizedPlacemarkCollections.get(id);

    if (colController != null) colController.update(params);
  }

  private void removeClusterizedPlacemarkCollection(Map<String, Object> params) {
    String id = (String) params.get("id");
    ClusterizedPlacemarkCollectionController colController = clusterizedPlacemarkCollections.get(id);

    if (colController != null) colController.remove();
    clusterizedPlacemarkCollections.remove(id);
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectTap(id, point);

    return consumeTapEvents;
  }
}
