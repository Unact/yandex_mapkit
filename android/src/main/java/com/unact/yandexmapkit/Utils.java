package com.unact.yandexmapkit;

import com.yandex.mapkit.ScreenPoint;
import com.yandex.mapkit.geometry.Circle;
import com.yandex.mapkit.geometry.LinearRing;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.Polygon;
import com.yandex.mapkit.geometry.Polyline;
import com.yandex.mapkit.map.CameraPosition;

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

  public static Map<String, Double> pointToJson(Point point) {
    Map<String, Double> pointMap = new HashMap<>();
    pointMap.put("latitude", point.getLatitude());
    pointMap.put("longitude", point.getLongitude());

    return pointMap;
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
}
