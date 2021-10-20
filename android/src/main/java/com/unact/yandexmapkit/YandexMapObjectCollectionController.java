package com.unact.yandexmapkit;

import android.content.Context;

import com.yandex.mapkit.map.MapObjectCollection;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexMapObjectCollectionController extends YandexMapObjectController {
  private final List<YandexCircleController> circleControllers = new ArrayList<>();
  private final List<YandexMapObjectCollectionController> mapObjectCollectionControllers = new ArrayList<>();
  private final List<YandexPlacemarkController> placemarkControllers = new ArrayList<>();
  private final List<YandexPolygonController> polygonControllers = new ArrayList<>();
  private final List<YandexPolylineController> polylineControllers = new ArrayList<>();
  private final Context context;
  private final MethodChannel methodChannel;
  private final MapObjectCollection mapObjectCollection;
  private final MapObjectCollection parent;
  public final String id;

  public YandexMapObjectCollectionController(
    MapObjectCollection root,
    String id,
    MethodChannel methodChannel,
    Context context
  ) {
    this.mapObjectCollection = root;
    this.id = id;
    this.parent = null;
    this.methodChannel = methodChannel;
    this.context = context;
  }

  public YandexMapObjectCollectionController(
    MapObjectCollection parent,
    Map<String, Object> params,
    MethodChannel methodChannel,
    Context context
  ) {
    MapObjectCollection mapObjectCollection = parent.addCollection();

    this.mapObjectCollection = mapObjectCollection;
    this.id = (String) params.get("id");
    this.parent = parent;
    this.context = context;
    this.methodChannel = methodChannel;

    mapObjectCollection.addTapListener(new YandexMapObjectTapListener(id, methodChannel));
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    mapObjectCollection.setZIndex(((Double) params.get("zIndex")).floatValue());
    updateMapObjects((Map<String, Object>) params.get("mapObjects"));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void remove(Map<String, Object> params) {
    updateMapObjects((Map<String, Object>) params.get("mapObjects"));

    if (parent != null) {
      parent.remove(mapObjectCollection);
    }
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
        default:
          break;
      }
    }
  }

  private void addCircle(Map<String, Object> params) {
    YandexCircleController circleController = new YandexCircleController(
      mapObjectCollection,
      params,
      methodChannel,
      context
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
        circleController.remove(params);
        circleControllers.remove(circleController);
        break;
      }
    }
  }

  private void addMapObjectCollection(Map<String, Object> params) {
    YandexMapObjectCollectionController mapObjectCollectionController = new YandexMapObjectCollectionController(
      mapObjectCollection,
      params,
      methodChannel,
      context
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
        mapObjectCollectionController.remove(params);
        mapObjectCollectionControllers.remove(mapObjectCollectionController);
        break;
      }
    }
  }

  private void addPlacemark(Map<String, Object> params) {
    YandexPlacemarkController placemarkController = new YandexPlacemarkController(
      mapObjectCollection,
      params,
      methodChannel,
      context
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
        placemarkController.remove(params);
        placemarkControllers.remove(placemarkController);
        break;
      }
    }
  }

  private void addPolygon(Map<String, Object> params) {
    YandexPolygonController polygonController = new YandexPolygonController(
      mapObjectCollection,
      params,
      methodChannel,
      context
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
        polygonController.remove(params);
        polygonControllers.remove(polygonController);
        break;
      }
    }
  }

  private void addPolyline(Map<String, Object> params) {
    YandexPolylineController polylineController = new YandexPolylineController(
      mapObjectCollection,
      params,
      methodChannel,
      context
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
        polylineController.remove(params);
        polylineControllers.remove(polylineController);
        break;
      }
    }
  }
}
