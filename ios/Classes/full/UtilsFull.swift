import YandexMapsMobile

class UtilsFull: UtilsLite {
  static func requestPointFromJson(_ json: [String: Any]) -> YMKRequestPoint {
    let point = pointFromJson(json["point"] as! [String: NSNumber])
    let pointType = YMKRequestPointType(rawValue: (json["requestPointType"] as! NSNumber).uintValue)!

    return YMKRequestPoint(
      point: point,
      type: pointType,
      pointContext: json["pointContext"] as? String,
      drivingArrivalPointId: json["drivingArrivalPointId"] as? String,
      indoorLevelId: json["indoorLevelId"] as? String
    )
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

  static func fitnessOptionsFromJson(_ json: [String: Any]) -> YMKFitnessOptions {
    return YMKFitnessOptions(
      avoidSteep: (json["avoidSteep"] as! NSNumber).boolValue,
      avoidStairs: (json["avoidStairs"] as! NSNumber).boolValue
    )
  }

  static func drivingOptionsFromJson(_ json: [String: Any]) -> YMKDrivingOptions {
    return YMKDrivingOptions(
      initialAzimuth: json["initialAzimuth"] as? NSNumber,
      routesCount: json["routesCount"] as? NSNumber,
      departureTime: json["departureTime"] as? NSNumber == nil ?
        nil :
        Date(timeIntervalSince1970: (json["departureTime"] as! NSNumber).doubleValue / 1000.0),
      annotationLanguage: json["annotationLanguage"] as? NSNumber,
      avoidanceFlags: json["avoidanceFlags"] as? [String: Any] == nil ?
        nil :
        avoidanceFlagsFromJson(json["avoidanceFlags"] as! [String: Any])
    )
  }

  static func avoidanceFlagsFromJson(_ json: [String: Any]) -> YMKDrivingAvoidanceFlags {
    return YMKDrivingAvoidanceFlags(
      avoidTolls: (json["avoidTolls"] as! NSNumber).boolValue,
      avoidUnpaved: (json["avoidUnpaved"] as! NSNumber).boolValue,
      avoidPoorCondition: (json["avoidPoorCondition"] as! NSNumber).boolValue,
      avoidRailwayCrossing: (json["avoidRailwayCrossing"] as! NSNumber).boolValue,
      avoidBoatFerry: (json["avoidBoatFerry"] as! NSNumber).boolValue,
      avoidFordCrossing: (json["avoidFordCrossing"] as! NSNumber).boolValue,
      avoidTunnel: (json["avoidTunnel"] as! NSNumber).boolValue,
      avoidHighway: (json["avoidHighway"] as! NSNumber).boolValue
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
      suggestWords: (json["suggestWords"] as! NSNumber).boolValue,
      strictBounds: (json["strictBounds"] as! NSNumber).boolValue
    )
  }
}
