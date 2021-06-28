part of yandex_mapkit;

class YandexDrivingRouter {
  static const String _channelName = 'yandex_mapkit/yandex_driving';

  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  static Future<DrivingSession> requestRoutes(
      List<RequestPoint> points) async {
    final int sessionId = _nextSessionId++;

    final List<Map<String, dynamic>> pointsRequest = points
        .map((RequestPoint requestPoint) => <String, dynamic>{
              'requestPointType':
                  requestPoint.requestPointType.toString().split('.').last,
              'point': <String, dynamic>{
                'latitude': requestPoint.point.latitude,
                'longitude': requestPoint.point.longitude,
              }
            })
        .toList();
    final Map<String, dynamic> request = <String, dynamic>{
      'points': pointsRequest,
      'sessionId': sessionId,
    };

    final Future<List<DrivingRoute>> futureRoutes = _channel
        .invokeListMethod<dynamic>('requestRoutes', request)
        .then((List<dynamic> resultRoutes) {
      return resultRoutes.map((dynamic map) {
        final List<dynamic> resultPoints = map['geometry'];
        final List<Point> points = resultPoints
            .map((dynamic resultPoint) => Point(
                  latitude: resultPoint['latitude'],
                  longitude: resultPoint['longitude'],
                ))
            .toList();
        return DrivingRoute(points);
      }).toList();
    });

    return DrivingSession(futureRoutes, () => _cancelSession(sessionId));
  }

  static Future<void> _cancelSession(int sessionId) async {
    await _channel.invokeMethod<void>(
        'cancelDrivingSession', <String, dynamic>{'sessionId': sessionId});
  }
}
