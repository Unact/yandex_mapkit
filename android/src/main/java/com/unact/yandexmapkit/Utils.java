package com.unact.yandexmapkit;

import android.graphics.PointF;

import com.yandex.mapkit.LocalizedValue;
import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.RequestPointType;
import com.yandex.mapkit.ScreenPoint;
import com.yandex.mapkit.directions.driving.DrivingOptions;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Circle;
import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.geometry.LinearRing;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.Polygon;
import com.yandex.mapkit.geometry.Polyline;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.Rect;
import com.yandex.mapkit.map.VisibleRegion;
import com.yandex.mapkit.search.SearchOptions;
import com.yandex.mapkit.search.SuggestOptions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Utils {
  @SuppressWarnings({"ConstantConditions"})
  public static Point pointFromJson(Map<String, Object> json) {
    return new Point(((Double) json.get("latitude")), ((Double) json.get("longitude")));
  }

  @SuppressWarnings({"ConstantConditions"})
  public static ScreenPoint screenPointFromJson(Map<String, Object> json) {
    return new ScreenPoint(((Double) json.get("x")).floatValue(), ((Double) json.get("y")).floatValue());
  }

  @SuppressWarnings({"ConstantConditions"})
  public static PointF rectPointFromJson(Map<String, Double> json) {
    return new PointF(((Double) json.get("dx")).floatValue(), ((Double) json.get("dy")).floatValue());
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Rect rectFromJson(Map<String, Object> json) {
    return new Rect(
      rectPointFromJson((Map<String, Double>) json.get("min")),
      rectPointFromJson((Map<String, Double>) json.get("max"))
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static RequestPoint requestPointFromJson(Map<String, Object> json) {
    return new RequestPoint(
      pointFromJson((Map<String, Object>) json.get("point")),
      RequestPointType.values()[(Integer) json.get("requestPointType")],
      null
    );
  }

  public static DrivingOptions drivingOptionsFromJson(Map<String, Object> json) {
    return new DrivingOptions(
      (Double) json.get("initialAzimuth"),
      (Integer) json.get("routesCount"),
      (Boolean) json.get("avoidTolls"),
      null,
      null
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static SearchOptions searchOptionsFromJson(Map<String, Object> json) {
    Point userPosition = json.get("userPosition") != null ?
      pointFromJson((Map<String, Object>) json.get("userPosition")) :
      null;

    return new SearchOptions(
      ((Number) json.get("searchType")).intValue(),
      (Integer) json.get("resultPageSize"),
      ((Number) json.get("searchSnippet")).intValue(),
      new ArrayList<String>(),
      userPosition,
      (String) json.get("origin"),
      (String) json.get("directPageId"),
      (String) json.get("appleCtx"),
      (Boolean) json.get("geometry"),
      (String) json.get("advertPageId"),
      (Boolean) json.get("suggestWords"),
      (Boolean) json.get("disableSpellingCorrection")
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static SuggestOptions suggestOptionsFromJson(Map<String, Object> json) {
    Point userPosition = json.get("userPosition") != null ?
      pointFromJson((Map<String, Object>) json.get("userPosition")) :
      null;

    return new SuggestOptions(
      ((Number) json.get("suggestType")).intValue(),
      userPosition,
      ((Boolean) json.get("suggestWords"))
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static BoundingBox boundingBoxFromJson(Map<String, Object> json) {
    return new BoundingBox(
      pointFromJson((Map<String, Object>) json.get("southWest")),
      pointFromJson((Map<String, Object>) json.get("northEast"))
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Geometry geometryFromJson(Map<String, Object> json) {
    if (json.get("point") != null) {
      return Geometry.fromPoint(pointFromJson((Map<String, Object>) json.get("point")));
    } else if (json.get("boundingBox") != null) {
      return Geometry.fromBoundingBox(boundingBoxFromJson((Map<String, Object>) json.get("boundingBox")));
    } else {
      return new Geometry();
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Circle circleFromJson(Map<String, Object> json) {
    return new Circle(
      pointFromJson((Map<String, Object>) json.get("center")),
      ((Double) json.get("radius")).floatValue()
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Polyline polylineFromJson(Map<String, Object> json) {
    ArrayList<Point> polylineCoordinates = new ArrayList<>();
    for (Map<String, Object> coordinates: (List<Map<String, Object>>) json.get("coordinates")) {
      polylineCoordinates.add(Utils.pointFromJson(coordinates));
    }

    return new Polyline(polylineCoordinates);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Polygon polygonFromJson(Map<String, Object> json) {
    ArrayList<Point> outerRingPolygonPoints = new ArrayList<>();
    ArrayList<LinearRing> innerRings = new ArrayList<>();
    for (Map<String, Object> c: (List<Map<String, Object>>) json.get("outerRingCoordinates")) {
      outerRingPolygonPoints.add(Utils.pointFromJson(c));
    }

    for (List<Map<String, Object>> cl: (List<List<Map<String, Object>>>) json.get("innerRingsCoordinates")) {
      ArrayList<Point> innerRingPolygonPoints = new ArrayList<>();

      for (Map<String, Object> c: cl) {
        innerRingPolygonPoints.add(Utils.pointFromJson(c));
      }

      innerRings.add(new LinearRing(innerRingPolygonPoints));
    }

    return new Polygon(new LinearRing(outerRingPolygonPoints), innerRings);
  }

  public static Map<String, Double> pointToJson(Point point) {
    Map<String, Double> pointMap = new HashMap<>();
    pointMap.put("latitude", point.getLatitude());
    pointMap.put("longitude", point.getLongitude());

    return pointMap;
  }

  public static Map<String, Object> boundingBoxToJson(BoundingBox boundingBox) {
    Map<String, Object> boundingBoxMap = new HashMap<>();
    boundingBoxMap.put("northEast", pointToJson(boundingBox.getNorthEast()));
    boundingBoxMap.put("southWest", pointToJson(boundingBox.getSouthWest()));

    return boundingBoxMap;
  }

  public static Map<String, Object> geometryToJson(Geometry geometry) {
    Map<String, Object> geometryMap = new HashMap<>();

    if (geometry.getPoint() != null) {
      geometryMap.put("point", pointToJson(geometry.getPoint()));

      return geometryMap;
    }

    if (geometry.getBoundingBox() != null) {
      geometryMap.put("boundingBox", boundingBoxToJson(geometry.getBoundingBox()));

      return geometryMap;
    }

    return geometryMap;
  }

  public static Map<String, Float> screenPointToJson(ScreenPoint screenPoint) {
    Map<String, Float> screenPointMap = new HashMap<>();
    screenPointMap.put("x", screenPoint.getX());
    screenPointMap.put("y", screenPoint.getY());

    return screenPointMap;
  }

  public static Map<String, Object> circleToJson(Circle circle) {
    Map<String, Object> circleMap = new HashMap<>();
    circleMap.put("center", pointToJson(circle.getCenter()));
    circleMap.put("radius", (double) circle.getRadius());

    return circleMap;
  }

  public static Map<String, Object> cameraPositionToJson(CameraPosition cameraPosition) {
    Map<String, Object> cameraPositionMap = new HashMap<>();
    cameraPositionMap.put("target", pointToJson(cameraPosition.getTarget()));
    cameraPositionMap.put("zoom", cameraPosition.getZoom());
    cameraPositionMap.put("tilt", cameraPosition.getTilt());
    cameraPositionMap.put("azimuth", cameraPosition.getAzimuth());

    return cameraPositionMap;
  }

  public static Map<String, Object> localizedValueToJson(LocalizedValue value) {
    Map<String, Object> valueMap = new HashMap<>();
    valueMap.put("value", value.getValue());
    valueMap.put("text", value.getText());

    return valueMap;
  }

  public static Map<String, Object> visibleRegionToJson(VisibleRegion region) {
    Map<String, Object> visibleRegionArguments = new HashMap<>();

    visibleRegionArguments.put("bottomLeft", Utils.pointToJson(region.getBottomLeft()));
    visibleRegionArguments.put("bottomRight", Utils.pointToJson(region.getBottomRight()));
    visibleRegionArguments.put("topLeft", Utils.pointToJson(region.getTopLeft()));
    visibleRegionArguments.put("topRight", Utils.pointToJson(region.getTopRight()));

    return visibleRegionArguments;
  }
}
