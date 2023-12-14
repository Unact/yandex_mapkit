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

  static func screenPointFromJson(_ json: [String: NSNumber]) -> YMKScreenPoint {
    return YMKScreenPoint(
      x: json["x"]!.floatValue,
      y: json["y"]!.floatValue
    )
  }

  static func screenRectFromJson(_ json: [String: Any]) -> YMKScreenRect {
    return YMKScreenRect(
      topLeft: screenPointFromJson(json["topLeft"] as! [String: NSNumber]),
      bottomRight: screenPointFromJson(json["bottomRight"] as! [String: NSNumber])
    )
  }

  static func rectPointFromJson(_ json: [String: NSNumber]) -> CGPoint {
    return CGPoint(
      x: json["dx"]!.doubleValue,
      y: json["dy"]!.doubleValue
    )
  }

  static func rectFromJson(_ json: [String: Any]) -> YMKRect {
    return YMKRect(
      min: rectPointFromJson(json["min"] as! [String: NSNumber]),
      max: rectPointFromJson(json["max"] as! [String: NSNumber])
    )
  }

  static func requestPointFromJson(_ json: [String: Any]) -> YMKRequestPoint {
    let point = pointFromJson(json["point"] as! [String: NSNumber])
    let pointType = YMKRequestPointType(rawValue: (json["requestPointType"] as! NSNumber).uintValue)!

    return YMKRequestPoint(point: point, type: pointType, pointContext: nil, drivingArrivalPointId: nil)
  }

  static func drivingOptionsFromJson(_ json: [String: Any]) -> YMKDrivingDrivingOptions {
    return YMKDrivingDrivingOptions(
      initialAzimuth: json["initialAzimuth"] as? NSNumber,
      routesCount: json["routesCount"] as? NSNumber,
      avoidTolls: json["avoidTolls"] as? NSNumber,
      avoidUnpaved: json["avoidUnpaved"] as? NSNumber,
      avoidPoorConditions: json["avoidPoorConditions"] as? NSNumber,
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
      userPosition: userPosition,
      origin: json["origin"] as? String,
      geometry: (json["geometry"] as! NSNumber).boolValue,
      disableSpellingCorrection: (json["disableSpellingCorrection"] as! NSNumber).boolValue,
      filters: nil
    )
  }

  static func suggestOptionsFromJson(_ json: [String: Any]) -> YMKSuggestOptions {
    let userPosition = json["userPosition"] as? [String: Any] != nil ?
      pointFromJson(json["userPosition"] as! [String: NSNumber]) :
      nil

    return YMKSuggestOptions(
      suggestTypes: YMKSuggestType.init(rawValue: (json["suggestType"] as! NSNumber).uintValue),
      userPosition: userPosition,
      suggestWords: (json["suggestWords"] as! NSNumber).boolValue
    )
  }

  static func geometryFromJson(_ json: [String: Any]) -> YMKGeometry {
    if let geometryPoint = json["point"] as? [String: NSNumber] {
      return YMKGeometry(point: pointFromJson(geometryPoint))
    } else if let geometryBoundingBox = json["boundingBox"] as? [String: Any] {
      return YMKGeometry(boundingBox: boundingBoxFromJson(geometryBoundingBox))
    } else if let geometryCircle = json["circle"] as? [String: Any] {
      return YMKGeometry(circle: circleFromJson(geometryCircle))
    } else if let geometryPolyline = json["polyline"] as? [String: Any] {
      return YMKGeometry(polyline: polylineFromJson(geometryPolyline))
    } else if let geometryPolygon = json["polygon"] as? [String: Any] {
      return YMKGeometry(polygon: polygonFromJson(geometryPolygon))
    } else if let geometryMultiPolygon = json["multiPolygon"] as? [String: Any] {
      return YMKGeometry(multiPolygon: multiPolygonFromJson(geometryMultiPolygon))
    }

    return YMKGeometry()
  }

  static func boundingBoxFromJson(_ json: [String: Any]) -> YMKBoundingBox {
    return YMKBoundingBox(
      southWest: pointFromJson(json["southWest"] as! [String: NSNumber]),
      northEast: pointFromJson(json["northEast"] as! [String: NSNumber])
    )
  }

  static func circleFromJson(_ json: [String: Any]) -> YMKCircle {
    return YMKCircle(
      center: pointFromJson(json["center"] as! [String: NSNumber]),
      radius: (json["radius"] as! NSNumber).floatValue
    )
  }

  static func linearRingFromJson(_ json: [String: Any]) -> YMKLinearRing {
    return YMKLinearRing(points: (json["points"] as! [[String: NSNumber]]).map { pointFromJson($0) })
  }

  static func multiPolygonFromJson(_ json: [String: Any]) -> YMKMultiPolygon {
    return YMKMultiPolygon(
      polygons: (json["polygons"] as! [[String: Any]]).map { polygonFromJson($0) }
    )
  }

  static func pointFromJson(_ json: [String: NSNumber]) -> YMKPoint {
    return YMKPoint(
      latitude: json["latitude"]!.doubleValue,
      longitude: json["longitude"]!.doubleValue
    )
  }

  static func polygonFromJson(_ json: [String: Any]) -> YMKPolygon {
    return YMKPolygon(
      outerRing: linearRingFromJson(json["outerRing"] as! [String: Any]),
      innerRings: (json["innerRings"] as! [[String: Any]]).map { linearRingFromJson($0) }
    )
  }

  static func polylineFromJson(_ json: [String: Any]) -> YMKPolyline {
    return YMKPolyline(points: (json["points"] as! [[String: NSNumber]]).map { pointFromJson($0) })
  }

  static func geometryToJson(_ geometry: YMKGeometry) -> [String: Any?] {
    return [
      "boundingBox": geometry.boundingBox == nil ? nil : boundingBoxToJson(geometry.boundingBox!),
      "circle": geometry.circle == nil ? nil : circleToJson(geometry.circle!),
      "multiPolygon": geometry.multiPolygon == nil ? nil : multiPolygonToJson(geometry.multiPolygon!),
      "point": geometry.point == nil ? nil : pointToJson(geometry.point!),
      "polygon": geometry.polygon == nil ? nil : polygonToJson(geometry.polygon!),
      "polyline": geometry.polyline == nil ? nil : polylineToJson(geometry.polyline!),
    ]
  }

  static func boundingBoxToJson(_ boundingBox: YMKBoundingBox) -> [String: Any] {
    return [
      "northEast": pointToJson(boundingBox.northEast),
      "southWest": pointToJson(boundingBox.southWest),
    ]
  }

  static func circleToJson(_ circle: YMKCircle) -> [String: Any] {
    return [
      "center": pointToJson(circle.center),
      "radius": circle.radius
    ]
  }

  static func linearRingToJson(_ linearRing: YMKLinearRing) -> [String: Any] {
    return [
      "points": linearRing.points.map({ pointToJson($0) })
    ]
  }

  static func multiPolygonToJson(_ multiPolygon: YMKMultiPolygon) -> [String: Any] {
    return [
      "polygons": multiPolygon.polygons.map({ polygonToJson($0) })
    ]
  }

  static func pointToJson(_ point: YMKPoint) -> [String: Any] {
    return [
      "latitude": point.latitude,
      "longitude": point.longitude
    ]
  }

  static func polygonToJson(_ polygon: YMKPolygon) -> [String: Any] {
    return [
      "outerRing": linearRingToJson(polygon.outerRing),
      "innerRings": polygon.innerRings.map({ linearRingToJson($0) })
    ]
  }

  static func polylineToJson(_ polyline: YMKPolyline) -> [String: Any] {
    return [
      "points": polyline.points.map({ pointToJson($0) })
    ]
  }

  static func screenPointToJson(_ screenPoint: YMKScreenPoint) -> [String: Any] {
    return [
      "x": screenPoint.x,
      "y": screenPoint.y
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

  static func visibleRegionToJson(_ region: YMKVisibleRegion) -> [String: Any] {
    return [
      "bottomLeft": pointToJson(region.bottomLeft),
      "bottomRight": pointToJson(region.bottomRight),
      "topLeft": pointToJson(region.topLeft),
      "topRight": pointToJson(region.topRight)
    ]
  }

  static func errorToJson(_ error: Error) -> [String: Any?] {
    var errorMessage = "Unknown error"

    if let underlyingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as? YRTError {
      if underlyingError.isKind(of: YRTNetworkError.self) {
        errorMessage = "Network error"
      } else if underlyingError.isKind(of: YRTRemoteError.self) {
        errorMessage = "Remote server error"
      }
    } else if let msg = (error as NSError).userInfo["message"] {
      errorMessage = msg as! String
    }

    return [
      "error": errorMessage
    ]
  }
}
