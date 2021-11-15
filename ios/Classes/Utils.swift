import YandexMapsMobile

class Utils {
  static func uiColor(fromInt value: Int64) -> UIColor {
    return UIColor(
      red: CGFloat((value & 0xFF0000) >> 16) / 0xFF,
      green: CGFloat((value & 0x00FF00) >> 8) / 0xFF,
      blue: CGFloat(value & 0x0000FF) / 0xFF,
      alpha: CGFloat((value & 0xFF000000) >> 24) / 0xFF
    )
  }

  static func pointFromJson(_ json: [String: NSNumber]) -> YMKPoint {
    return YMKPoint(
      latitude: json["latitude"]!.doubleValue,
      longitude: json["longitude"]!.doubleValue
    )
  }

  static func screenPointFromJson(_ json: [String: NSNumber]) -> YMKScreenPoint {
    return YMKScreenPoint(
      x: json["x"]!.floatValue,
      y: json["y"]!.floatValue
    )
  }

  static func pointToJson(_ point: YMKPoint) -> [String: Any] {
    return [
      "latitude": point.latitude,
      "longitude": point.longitude
    ]
  }

  static func screenPointToJson(_ screenPoint: YMKScreenPoint) -> [String: Any] {
    return [
      "x": screenPoint.x,
      "y": screenPoint.y
    ]
  }

  static func circleToJson(_ circle: YMKCircle) -> [String: Any] {
    return [
      "center": pointToJson(circle.center),
      "radius": circle.radius
    ]
  }

  static func cameraPositionToJson(_ cameraPosition: YMKCameraPosition) -> [String: Any] {
    return [
      "target": pointToJson(cameraPosition.target),
      "zoom": cameraPosition.zoom,
      "tilt": cameraPosition.tilt,
      "azimuth": cameraPosition.azimuth,
    ]
  }

  static func circleFromJson(_ json: [String: Any]) -> YMKCircle {
    return YMKCircle(
      center: pointFromJson(json["center"] as! [String: NSNumber]),
      radius: (json["radius"] as! NSNumber).floatValue
    )
  }

  static func polylineFromJson(_ json: [String: Any]) -> YMKPolyline {
    return YMKPolyline(points: (json["coordinates"] as! [[String: NSNumber]]).map { pointFromJson($0) })
  }

  static func polygonFromJson(_ json: [String: Any]) -> YMKPolygon {
    return YMKPolygon(
      outerRing: YMKLinearRing(points: (json["outerRingCoordinates"] as! [[String: NSNumber]]).map { pointFromJson($0) }),
      innerRings: (json["innerRingsCoordinates"] as! [[[String: NSNumber]]]).map {
        YMKLinearRing(points: $0.map { pointFromJson($0) })
      }
    )
  }
}
