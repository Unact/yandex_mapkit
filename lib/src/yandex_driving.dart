part of yandex_mapkit;

/// Interface for the driving router.
class YandexDriving {
  static const String _channelName = 'yandex_mapkit/yandex_driving';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  /// Builds a route.
  static DrivingResultWithSession requestRoutes(
      {required List<RequestPoint> points,
      required DrivingOptions drivingOptions}) {
    final params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'points': points
          .map((RequestPoint requestPoint) => requestPoint.toJson())
          .toList(),
      'drivingOptions': drivingOptions.toJson()
    };
    final result = _channel
        .invokeMethod('requestRoutes', params)
        .then((result) => DrivingSessionResult._fromJson(result));

    return DrivingResultWithSession._(
        session: DrivingSession._(id: params['sessionId']), result: result);
  }
}
