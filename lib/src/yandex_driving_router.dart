part of yandex_mapkit;

class YandexDrivingRouter {
  static const String _channelName = 'yandex_mapkit/yandex_driving';

  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  static Future<DrivingSession> requestRoutes(List<RequestPoint> points) async {
    final sessionId = _nextSessionId++;

    final pointsRequest = points
        .map((RequestPoint requestPoint) => <String, dynamic>{
              'requestPointType':
                  requestPoint.requestPointType.toString().split('.').last,
              'point': <String, dynamic>{
                'latitude': requestPoint.point.latitude,
                'longitude': requestPoint.point.longitude,
              }
            })
        .toList();
    final request = <String, dynamic>{
      'points': pointsRequest,
      'sessionId': sessionId,
    };

    final futureRoutes = _channel
        .invokeMethod('requestRoutes', request)
        .then((resultRoutes) => _mapSessionResult(resultRoutes));

    return DrivingSession(futureRoutes, () => _cancelSession(sessionId));
  }

  static DrivingSessionResult _mapSessionResult(Map<dynamic, dynamic> result) {
    final List<dynamic>? resultRoutes = result['routes'];
    final String? error = result['error'];
    final routes = resultRoutes?.map((dynamic map) {
      final List<dynamic> resultPoints = map['geometry'];
      final points = resultPoints
          .map((dynamic resultPoint) => Point(
                latitude: resultPoint['latitude'],
                longitude: resultPoint['longitude'],
              ))
          .toList();
      final dynamic weight = map['metadata']['weight'];
      final metadata = DrivingSectionMetadata(
        DrivingWeight(
          LocalizedValue(
            weight['time']['value'],
            weight['time']['text'],
          ),
          LocalizedValue(
            weight['timeWithTraffic']['value'],
            weight['timeWithTraffic']['text'],
          ),
          LocalizedValue(
            weight['distance']['value'],
            weight['distance']['text'],
          ),
        ),
      );
      return DrivingRoute(points, metadata);
    }).toList();

    return DrivingSessionResult(routes, error);
  }

  static Future<void> _cancelSession(int sessionId) async {
    await _channel.invokeMethod<void>(
        'cancelDrivingSession', <String, dynamic>{'sessionId': sessionId});
  }
}
