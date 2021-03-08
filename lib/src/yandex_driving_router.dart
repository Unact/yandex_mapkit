import 'package:flutter/services.dart';
import 'package:yandex_mapkit/src/types/driving/driving_route.dart';
import 'package:yandex_mapkit/src/types/driving/request_point.dart';

class YandexDrivingRouter {
  static const String _channelName = 'yandex_mapkit/yandex_driving';

  static const MethodChannel _channel = MethodChannel(_channelName);

  Future<List<DrivingRoute>> requestRoutes(List<RequestPoint> points) async {
    final List<Map<String, dynamic>> pointsRequest = points
        .map((RequestPoint requestPoint) => <String, dynamic>{
              'requestPointType': requestPoint.requestPointType.toString().split('.').last,
              'point': <String, dynamic>{
                'latitude': requestPoint.point.latitude,
                'longitude': requestPoint.point.longitude,
              }
            })
        .toList();
    return await _channel.invokeListMethod<DrivingRoute>('requestDrivingRoute', pointsRequest);
  }
}
