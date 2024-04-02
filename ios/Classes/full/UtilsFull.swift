import YandexMapsMobile

class UtilsFull: UtilsLite {
  static func requestPointFromJson(_ json: [String: Any]) -> YMKRequestPoint {
    let point = pointFromJson(json["point"] as! [String: NSNumber])
    let pointType = YMKRequestPointType(rawValue: (json["requestPointType"] as! NSNumber).uintValue)!

    return YMKRequestPoint(point: point, type: pointType, pointContext: nil, drivingArrivalPointId: nil)
  }

  static func timeOptionsFromJson(_ json: [String: Any]) -> YMKTimeOptions {
    return YMKTimeOptions(
      departureTime: json["departureTime"] as? NSNumber == nil ?
        nil :
        Date(timeIntervalSince1970: (json["departureTime"] as! NSNumber).doubleValue / 1000.0),
      arrivalTime: json["arrivalTime"] as? NSNumber == nil ?
        nil :
        Date(timeIntervalSince1970: (json["arrivalTime"] as! NSNumber).doubleValue / 1000.0)
    )
  }

  static func drivingOptionsFromJson(_ json: [String: Any]) -> YMKDrivingOptions {
    return YMKDrivingOptions(
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
      snippets: YMKSearchSnippet(),
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
}
