part of yandex_mapkit;

/// Interface for the Bicycle router.
class YandexBicycle {
  static const String _channelName = 'yandex_mapkit/yandex_bicycle';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  /// Builds a route.
  static BicycleResultWithSession requestRoutes(
      {required List<RequestPoint> points,
      required BicycleVehicleType bicycleVehicleType}) {
    final params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'bicycleVehicleType': bicycleVehicleType.index,
      'points': points
          .map((RequestPoint requestPoint) => requestPoint.toJson())
          .toList(),
    };
    final result = _channel
        .invokeMethod('requestRoutes', params)
        .then((result) => BicycleSessionResult._fromJson(result));

    return BicycleResultWithSession._(
        session: BicycleSession._(id: params['sessionId']), result: result);
  }
}
