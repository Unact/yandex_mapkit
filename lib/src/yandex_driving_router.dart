part of yandex_mapkit;

class YandexDrivingRouter {
  static const String _channelName = 'yandex_mapkit/yandex_driving';

  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<List<DrivingRoute>> requestRoutes(List<RequestPoint> points) async {
    final List<Map<String, dynamic>> pointsRequest = points
        .map((RequestPoint requestPoint) => <String, dynamic>{
              'requestPointType': requestPoint.requestPointType.toString().split('.').last,
              'point': <String, dynamic>{
                'latitude': requestPoint.point.latitude,
                'longitude': requestPoint.point.longitude,
              }
            })
        .toList();
    final Map<String, dynamic> request = <String, dynamic>{'points': pointsRequest};
    final List<dynamic> resultRoutes = await _channel.invokeListMethod<dynamic>('requestRoutes', request);
    final List<DrivingRoute> routes = resultRoutes.map((dynamic map) {
      List<dynamic> resultPoints = map['geometry'];
      final List<Point> points = resultPoints
          .map((dynamic resultPoint) => Point(
                latitude: resultPoint['latitude'],
                longitude: resultPoint['longitude'],
              ))
          .toList();
      return DrivingRoute(points);
    }).toList();

    return routes;
  }
}
