package com.unact.yandexmapkit;

import android.graphics.PointF;

import androidx.annotation.NonNull;

import com.yandex.mapkit.LocalizedValue;
import com.yandex.mapkit.RequestPoint;
import com.yandex.mapkit.RequestPointType;
import com.yandex.mapkit.ScreenPoint;
import com.yandex.mapkit.ScreenRect;
import com.yandex.mapkit.directions.driving.DrivingOptions;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.geometry.Circle;
import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.geometry.LinearRing;
import com.yandex.mapkit.geometry.MultiPolygon;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.Polygon;
import com.yandex.mapkit.geometry.Polyline;
import com.yandex.mapkit.map.CameraPosition;
import com.yandex.mapkit.map.Rect;
import com.yandex.mapkit.map.VisibleRegion;
import com.yandex.mapkit.search.SearchOptions;
import com.yandex.mapkit.search.SuggestOptions;
import com.yandex.runtime.Error;
import com.yandex.runtime.network.NetworkError;
import com.yandex.runtime.network.RemoteError;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Utils {
  @SuppressWarnings({"ConstantConditions"})
  public static ScreenPoint screenPointFromJson(Map<String, Object> json) {
    return new ScreenPoint(((Double) json.get("x")).floatValue(), ((Double) json.get("y")).floatValue());
  }

  @SuppressWarnings({"ConstantConditions", "unchecked"})
  public static ScreenRect screenRectFromJson(Map<String, Object> json) {
    return new ScreenRect(
      screenPointFromJson(((Map<String, Object>) json.get("topLeft"))),
      screenPointFromJson(((Map<String, Object>) json.get("bottomRight")))
    );
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
      null,
      null
    );
  }

  public static DrivingOptions drivingOptionsFromJson(Map<String, Object> json) {
    return new DrivingOptions(
      (Double) json.get("initialAzimuth"),
      (Integer) json.get("routesCount"),
      (Boolean) json.get("avoidTolls"),
      (Boolean) json.get("avoidUnpaved"),
      (Boolean) json.get("avoidPoorConditions"),
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
      userPosition,
      (String) json.get("origin"),
      (Boolean) json.get("geometry"),
      (Boolean) json.get("disableSpellingCorrection"),
      null
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
  public static Geometry geometryFromJson(Map<String, Object> json) {
    if (json.get("point") != null) {
      return Geometry.fromPoint(pointFromJson((Map<String, Object>) json.get("point")));
    } else if (json.get("boundingBox") != null) {
      return Geometry.fromBoundingBox(boundingBoxFromJson((Map<String, Object>) json.get("boundingBox")));
    } else if (json.get("circle") != null) {
      return Geometry.fromCircle(circleFromJson((Map<String, Object>) json.get("circle")));
    } else if (json.get("boundingBox") != null) {
      return Geometry.fromPolyline(polylineFromJson((Map<String, Object>) json.get("polyline")));
    } else if (json.get("polygon") != null) {
      return Geometry.fromPolygon(polygonFromJson((Map<String, Object>) json.get("polygon")));
    } else if (json.get("multiPolygon") != null) {
      return Geometry.fromMultiPolygon(multiPolygonFromJson((Map<String, Object>) json.get("multiPolygon")));
    } else {
      return new Geometry();
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static BoundingBox boundingBoxFromJson(Map<String, Object> json) {
    return new BoundingBox(
      pointFromJson((Map<String, Object>) json.get("southWest")),
      pointFromJson((Map<String, Object>) json.get("northEast"))
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Circle circleFromJson(Map<String, Object> json) {
    return new Circle(
      pointFromJson((Map<String, Object>) json.get("center")),
      ((Double) json.get("radius")).floatValue()
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static LinearRing linearRingFromJson(Map<String, Object> json) {
    ArrayList<Point> points = new ArrayList<>();

    for (Map<String, Object> pointJson: (List<Map<String, Object>>) json.get("points")) {
      points.add(pointFromJson(pointJson));
    }

    return new LinearRing(points);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static MultiPolygon multiPolygonFromJson(Map<String, Object> json) {
    ArrayList<Polygon> polygons = new ArrayList<>();

    for (Map<String, Object> polygonJson: (List<Map<String, Object>>) json.get("polygons")) {
      polygons.add(polygonFromJson(polygonJson));
    }

    return new MultiPolygon(polygons);
  }

  @SuppressWarnings({"ConstantConditions"})
  public static Point pointFromJson(Map<String, Object> json) {
    return new Point(((Double) json.get("latitude")), ((Double) json.get("longitude")));
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Polygon polygonFromJson(Map<String, Object> json) {
    ArrayList<LinearRing> innerRings = new ArrayList<>();

    for (Map<String, Object> linearRingJson: (List<Map<String, Object>>) json.get("innerRings")) {
      innerRings.add(linearRingFromJson(linearRingJson));
    }

    return new Polygon(
      linearRingFromJson((Map<String, Object>) json.get("outerRing")),
      innerRings
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static Polyline polylineFromJson(Map<String, Object> json) {
    ArrayList<Point> points = new ArrayList<>();

    for (Map<String, Object> pointJson: (List<Map<String, Object>>) json.get("points")) {
      points.add(pointFromJson(pointJson));
    }

    return new Polyline(points);
  }

  public static Map<String, Object> geometryToJson(Geometry geometry) {
    Map<String, Object> geometryMap = new HashMap<>();

    geometryMap.put(
      "boundingBox",
      geometry.getBoundingBox() == null ? null : boundingBoxToJson(geometry.getBoundingBox())
    );
    geometryMap.put(
      "circle",
      geometry.getCircle() == null ? null : circleToJson(geometry.getCircle())
    );
    geometryMap.put(
      "multiPolygon",
      geometry.getMultiPolygon() == null ? null : multiPolygonToJson(geometry.getMultiPolygon())
    );
    geometryMap.put(
      "point",
      geometry.getPoint() == null ? null : pointToJson(geometry.getPoint())
    );
    geometryMap.put(
      "polygon",
      geometry.getPolygon() == null ? null : polygonToJson(geometry.getPolygon())
    );
    geometryMap.put(
      "polyline",
      geometry.getPolyline() == null ? null : polylineToJson(geometry.getPolyline())
    );

    return geometryMap;
  }

  public static Map<String, Object> boundingBoxToJson(BoundingBox boundingBox) {
    Map<String, Object> boundingBoxMap = new HashMap<>();
    boundingBoxMap.put("northEast", pointToJson(boundingBox.getNorthEast()));
    boundingBoxMap.put("southWest", pointToJson(boundingBox.getSouthWest()));

    return boundingBoxMap;
  }

  public static Map<String, Object> circleToJson(Circle circle) {
    Map<String, Object> circleMap = new HashMap<>();
    circleMap.put("center", pointToJson(circle.getCenter()));
    circleMap.put("radius", (double) circle.getRadius());

    return circleMap;
  }

  public static Map<String, Object> linearRingToJson(LinearRing linearRing) {
    Map<String, Object> linearRingMap = new HashMap<>();
    ArrayList<Map<String, Double>> points = new ArrayList<>();

    for (Point point: linearRing.getPoints()) {
      points.add(pointToJson(point));
    }

    linearRingMap.put("points", points);

    return linearRingMap;
  }

  public static Map<String, Object> multiPolygonToJson(MultiPolygon multiPolygon) {
    Map<String, Object> multiPolygonMap = new HashMap<>();
    ArrayList<Map<String, Object>> polygons = new ArrayList<>();

    for (Polygon polygon: multiPolygon.getPolygons()) {
      polygons.add(polygonToJson(polygon));
    }

    multiPolygonMap.put("polygons", polygons);

    return multiPolygonMap;
  }

  public static Map<String, Double> pointToJson(Point point) {
    Map<String, Double> pointMap = new HashMap<>();
    pointMap.put("latitude", point.getLatitude());
    pointMap.put("longitude", point.getLongitude());

    return pointMap;
  }

  public static Map<String, Object> polygonToJson(Polygon polygon) {
    Map<String, Object> polygonMap = new HashMap<>();
    ArrayList<Map<String, Object>> linearRings = new ArrayList<>();

    for (LinearRing linearRing: polygon.getInnerRings()) {
      linearRings.add(linearRingToJson(linearRing));
    }

    polygonMap.put("outerRing", linearRingToJson(polygon.getOuterRing()));
    polygonMap.put("innerRings", linearRings);

    return polygonMap;
  }

  public static Map<String, Object> polylineToJson(Polyline polyline) {
    Map<String, Object> polylineMap = new HashMap<>();
    ArrayList<Map<String, Double>> points = new ArrayList<>();

    for (Point point: polyline.getPoints()) {
      points.add(pointToJson(point));
    }

    polylineMap.put("points", points);

    return polylineMap;
  }

  public static Map<String, Float> screenPointToJson(ScreenPoint screenPoint) {
    Map<String, Float> screenPointMap = new HashMap<>();
    screenPointMap.put("x", screenPoint.getX());
    screenPointMap.put("y", screenPoint.getY());

    return screenPointMap;
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

    visibleRegionArguments.put("bottomLeft", pointToJson(region.getBottomLeft()));
    visibleRegionArguments.put("bottomRight", pointToJson(region.getBottomRight()));
    visibleRegionArguments.put("topLeft", pointToJson(region.getTopLeft()));
    visibleRegionArguments.put("topRight", pointToJson(region.getTopRight()));

    return visibleRegionArguments;
  }

  public static Map<String, Object> errorToJson(@NonNull Error error) {
    Map<String, Object> errorMap = new HashMap<>();
    String errorMessage = "Unknown error";

    if (error instanceof NetworkError) {
      errorMessage = "Network error";
    }

    if (error instanceof RemoteError) {
      errorMessage = "Remote server error";
    }

    errorMap.put("error", errorMessage);

    return errorMap;
  }
}
