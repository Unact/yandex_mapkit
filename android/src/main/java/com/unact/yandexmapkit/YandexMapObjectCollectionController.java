package com.unact.yandexmapkit;

import com.yandex.mapkit.map.MapObjectCollection;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class YandexMapObjectCollectionController extends YandexMapObjectController {
  private final List<YandexMapObjectCollectionController> mapObjectCollectionControllers = new ArrayList<>();
  private final List<YandexClusterizedPlacemarkCollectionController> clusterizedPlacemarkCollectionControllers =
    new ArrayList<>();
  private final List<YandexCircleController> circleControllers = new ArrayList<>();
  private final List<YandexPlacemarkController> placemarkControllers = new ArrayList<>();
  private final List<YandexPolygonController> polygonControllers = new ArrayList<>();
  private final List<YandexPolylineController> polylineControllers = new ArrayList<>();
  public final MapObjectCollection mapObjectCollection;
  private final YandexMapObjectTapListener tapListener;
  private final WeakReference<YandexMapController> controller;
  public final String id;

  public YandexMapObjectCollectionController(
    MapObjectCollection root,
    String id,
    WeakReference<YandexMapController> controller
  ) {
    this.mapObjectCollection = root;
    this.id = id;
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);

    mapObjectCollection.setUserData(this.id);
    mapObjectCollection.addTapListener(tapListener);
  }

  public YandexMapObjectCollectionController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    MapObjectCollection mapObjectCollection = parent.addCollection();

    this.mapObjectCollection = mapObjectCollection;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);

    mapObjectCollection.setUserData(this.id);
    mapObjectCollection.addTapListener(tapListener);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    mapObjectCollection.setZIndex(((Double) params.get("zIndex")).floatValue());
    mapObjectCollection.setVisible((Boolean) params.get("isVisible"));
    updateMapObjects((Map<String, Object>) params.get("mapObjects"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void remove() {
    for (YandexClusterizedPlacemarkCollectionController colController : clusterizedPlacemarkCollectionControllers) {
      colController.remove();
    }
    for (YandexCircleController circleController : circleControllers) {
      circleController.remove();
    }
    for (YandexMapObjectController mapObjectCollectionController : mapObjectCollectionControllers) {
      mapObjectCollectionController.remove();
    }
    for (YandexPlacemarkController placemarkController : placemarkControllers) {
      placemarkController.remove();
    }
    for (YandexPolygonController polygonController : polygonControllers) {
      polygonController.remove();
    }
    for (YandexPolylineController polylineController : polylineControllers) {
      polylineController.remove();
    }

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
        case "Circle":
          addCircle(el);
          break;
        case "MapObjectCollection":
          addMapObjectCollection(el);
          break;
        case "Placemark":
          addPlacemark(el);
          break;
        case "Polygon":
          addPolygon(el);
          break;
        case "Polyline":
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
        case "Circle":
          changeCircle(el);
          break;
        case "MapObjectCollection":
          changeMapObjectCollection(el);
          break;
        case "Placemark":
          changePlacemark(el);
          break;
        case "Polygon":
          changePolygon(el);
          break;
        case "Polyline":
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
        case "Circle":
          removeCircle(el);
          break;
        case "MapObjectCollection":
          removeMapObjectCollection(el);
          break;
        case "Placemark":
          removePlacemark(el);
          break;
        case "Polygon":
          removePolygon(el);
          break;
        case "Polyline":
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
    YandexCircleController circleController = new YandexCircleController(
      mapObjectCollection,
      params,
      controller
    );

    circleControllers.add(circleController);
  }

  private void changeCircle(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexCircleController circleController : circleControllers) {
      if (circleController.id.equals(id)) {
        circleController.update(params);
        break;
      }
    }
  }

  private void removeCircle(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexCircleController circleController : circleControllers) {
      if (circleController.id.equals(id)) {
        circleController.remove();
        circleControllers.remove(circleController);
        break;
      }
    }
  }

  private void addMapObjectCollection(Map<String, Object> params) {
    YandexMapObjectCollectionController mapObjectCollectionController = new YandexMapObjectCollectionController(
      mapObjectCollection,
      params,
      controller
    );

    mapObjectCollectionControllers.add(mapObjectCollectionController);
  }

  private void changeMapObjectCollection(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexMapObjectCollectionController mapObjectCollectionController : mapObjectCollectionControllers) {
      if (mapObjectCollectionController.id.equals(id)) {
        mapObjectCollectionController.update(params);
        break;
      }
    }
  }

  private void removeMapObjectCollection(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexMapObjectCollectionController mapObjectCollectionController : mapObjectCollectionControllers) {
      if (mapObjectCollectionController.id.equals(id)) {
        mapObjectCollectionController.remove();
        mapObjectCollectionControllers.remove(mapObjectCollectionController);
        break;
      }
    }
  }

  private void addPlacemark(Map<String, Object> params) {
    YandexPlacemarkController placemarkController = new YandexPlacemarkController(
      mapObjectCollection,
      params,
      controller
    );

    placemarkControllers.add(placemarkController);
  }

  private void changePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPlacemarkController placemarkController : placemarkControllers) {
      if (placemarkController.id.equals(id)) {
        placemarkController.update(params);
        break;
      }
    }
  }

  private void removePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPlacemarkController placemarkController : placemarkControllers) {
      if (placemarkController.id.equals(id)) {
        placemarkController.remove();
        placemarkControllers.remove(placemarkController);
        break;
      }
    }
  }

  private void addPolygon(Map<String, Object> params) {
    YandexPolygonController polygonController = new YandexPolygonController(
      mapObjectCollection,
      params,
      controller
    );

    polygonControllers.add(polygonController);
  }

  private void changePolygon(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPolygonController polygonController : polygonControllers) {
      if (polygonController.id.equals(id)) {
        polygonController.update(params);
        break;
      }
    }
  }

  private void removePolygon(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPolygonController polygonController : polygonControllers) {
      if (polygonController.id.equals(id)) {
        polygonController.remove();
        polygonControllers.remove(polygonController);
        break;
      }
    }
  }

  private void addPolyline(Map<String, Object> params) {
    YandexPolylineController polylineController = new YandexPolylineController(
      mapObjectCollection,
      params,
      controller
    );

    polylineControllers.add(polylineController);
  }

  private void changePolyline(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPolylineController polylineController : polylineControllers) {
      if (polylineController.id.equals(id)) {
        polylineController.update(params);
        break;
      }
    }
  }

  private void removePolyline(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPolylineController polylineController : polylineControllers) {
      if (polylineController.id.equals(id)) {
        polylineController.remove();
        polylineControllers.remove(polylineController);
        break;
      }
    }
  }

  private void addClusterizedPlacemarkCollection(Map<String, Object> params) {
    YandexClusterizedPlacemarkCollectionController colController = new YandexClusterizedPlacemarkCollectionController(
      mapObjectCollection,
      params,
      controller
    );

    clusterizedPlacemarkCollectionControllers.add(colController);
  }

  private void changeClusterizedPlacemarkCollection(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexClusterizedPlacemarkCollectionController colController : clusterizedPlacemarkCollectionControllers) {
      if (colController.id.equals(id)) {
        colController.update(params);
        break;
      }
    }
  }

  private void removeClusterizedPlacemarkCollection(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexClusterizedPlacemarkCollectionController colController : clusterizedPlacemarkCollectionControllers) {
      if (colController.id.equals(id)) {
        colController.remove();
        clusterizedPlacemarkCollectionControllers.remove(colController);
        break;
      }
    }
  }
}
