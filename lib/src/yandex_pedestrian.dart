part of yandex_mapkit;

/// Interface for the pedestrian router.
class YandexPedestrian {
  static const String _channelName = 'yandex_mapkit/yandex_pedestrian';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  /// Builds a route.
  static PedestrianResultWithSession requestRoutes({
    required List<RequestPoint> points,
  }) {
    final params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'points': points.map((RequestPoint requestPoint) => requestPoint.toJson()).toList()
    };
    final result = _channel
        .invokeMethod('requestRoutes', params)
        .then((result) => PedestrianSessionResult._fromJson(result));

    return PedestrianResultWithSession._(
        session: PedestrianSession._(id: params['sessionId']),
        result: result
    );
  }
}