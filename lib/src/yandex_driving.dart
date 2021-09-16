part of yandex_mapkit;

class YandexDriving {
  static const String _channelName = 'yandex_mapkit/yandex_driving';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  static DrivingResultWithSession requestRoutes(List<RequestPoint> points) {
    var pointsRequest = points
      .map((RequestPoint requestPoint) => <String, dynamic>{
          'requestPointType': requestPoint.requestPointType.value,
          'point': requestPoint.point.toJson()
        })
      .toList();
    var params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'points': pointsRequest,
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
