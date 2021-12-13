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

  static func rectPointFromJson(_ json: [String: NSNumber]) -> CGPoint {
    return CGPoint(
      x: json["dx"]!.doubleValue,
      y: json["dy"]!.doubleValue
    )
  }

  static func requestPointFromJson(_ json: [String: Any]) -> YMKRequestPoint {
    let point = pointFromJson(json["point"] as! [String: NSNumber])
    let pointType = YMKRequestPointType(rawValue: (json["requestPointType"] as! NSNumber).uintValue)!

    return YMKRequestPoint(point: point, type: pointType, pointContext: nil)
  }

  static func drivingOptionsFromJson(_ json: [String: Any]) -> YMKDrivingDrivingOptions {
    return YMKDrivingDrivingOptions(
      initialAzimuth: json["initialAzimuth"] as? NSNumber,
      routesCount: json["routesCount"] as? NSNumber,
      avoidTolls: json["avoidTolls"] as? NSNumber,
      departureTime: nil,
      annotationLanguage: nil
    )
  }

  static func searchOptionsFromJson(_ json: [String: Any]) -> YMKSearchOptions {
    let userPosition = json["userPosition"] as? [String: Any] != nil ?
      pointFromJson(json["userPosition"] as! [String: NSNumber]) :
      nil

    return YMKSearchOptions(
      searchTypes: YMKSearchType(rawValue: (json["searchType"] as! NSNumber).uintValue),
      resultPageSize: json["resultPageSize"] as? NSNumber,
      snippets: YMKSearchSnippet(rawValue: (json["searchSnippet"] as! NSNumber).uintValue),
      experimentalSnippets: [String](),
      userPosition: userPosition,
      origin: json["origin"] as? String,
      directPageId: json["directPageId"] as? String,
      appleCtx: json["appleCtx"] as? String,
      geometry: (json["geometry"] as! NSNumber).boolValue,
      advertPageId: json["advertPageId"] as? String,
      suggestWords: (json["suggestWords"] as! NSNumber).boolValue,
      disableSpellingCorrection: (json["disableSpellingCorrection"] as! NSNumber).boolValue
    )
  }

  static func suggestOptionsFromJson(_ json: [String: Any]) -> YMKSuggestOptions {
    let userPosition = json["userPosition"] != nil ?
      pointFromJson(json["userPosition"] as! [String: NSNumber]) :
      nil

    return YMKSuggestOptions(
      suggestTypes: YMKSuggestType.init(rawValue: (json["suggestType"] as! NSNumber).uintValue),
      userPosition: userPosition,
      suggestWords: (json["suggestWords"] as! NSNumber).boolValue
    )
  }

  static func pointToJson(_ point: YMKPoint) -> [String: Any] {
    return [
      "latitude": point.latitude,
      "longitude": point.longitude
    ]
  }

  static func boundingBoxToJson(_ boundingBox: YMKBoundingBox) -> [String: Any] {
    return [
      "northEast": pointToJson(boundingBox.northEast),
      "southWest": pointToJson(boundingBox.southWest),
    ]
  }

  static func geometryToJson(_ geometry: YMKGeometry) -> [String: Any] {
    if geometry.point != nil {
      return [
        "point": pointToJson(geometry.point!)
      ]
    }

    if geometry.boundingBox != nil {
      return [
        "boundingBox": boundingBoxToJson(geometry.boundingBox!)
      ]
    }

    return [:]
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

  static func localizedValueToJson(_ value: YMKLocalizedValue) -> [String: Any?] {
    [
      "value": value.value,
      "text": value.text
    ]
  }

  static func boundingBoxFromJson(_ json: [String: Any]) -> YMKBoundingBox {
    return YMKBoundingBox(
      southWest: Utils.pointFromJson(json["southWest"] as! [String: NSNumber]),
      northEast: Utils.pointFromJson(json["northEast"] as! [String: NSNumber])
    )
  }

  static func geometryFromJson(_ json: [String: Any]) -> YMKGeometry {
    if let geometryPoint = json["point"] as? [String: NSNumber] {
      return YMKGeometry(point: Utils.pointFromJson(geometryPoint))
    } else {
      return YMKGeometry(boundingBox: Utils.boundingBoxFromJson(json["boundingBox"] as! [String: Any]))
    }
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
