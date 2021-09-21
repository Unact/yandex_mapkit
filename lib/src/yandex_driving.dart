part of yandex_mapkit;

class YandexDriving {
  static const String _channelName = 'yandex_mapkit/yandex_driving';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  static DrivingResultWithSession requestRoutes({
    required List<RequestPoint> points
  }) {
    var params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'points': points.map((RequestPoint requestPoint) => requestPoint.toJson()).toList()
    };
    var result = _channel
      .invokeMethod('requestRoutes', params)
      .then((result) => DrivingSessionResult.fromJson(result));

    return DrivingResultWithSession._(
      session: DrivingSession._(id: params['sessionId']),
      result: result
    );
  }
}
