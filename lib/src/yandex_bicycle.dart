part of '../yandex_mapkit.dart';

/// Interface for the Bicycle router.
class YandexBicycle {
  static const String _channelName = 'yandex_mapkit/yandex_bicycle';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextId = 0;

  /// Builds a route.
  static Future<(BicycleSession, Future<BicycleSessionResult>)> requestRoutes({
    required List<RequestPoint> points,
    required BicycleVehicleType bicycleVehicleType
  }) async {
    final session = await _initSession();

    return (session, session._requestRoutes(points: points, bicycleVehicleType: bicycleVehicleType));
  }

  /// Initialize session on native side for further use
  static Future<BicycleSession> _initSession() async {
    final id = _nextId++;

    await _channel.invokeMethod('initSession', { 'id': id });

    return BicycleSession._(id: id);
  }
}
