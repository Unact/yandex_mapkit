part of '../yandex_mapkit.dart';

/// Interface for the driving router.
class YandexDriving {
  static const String _channelName = 'yandex_mapkit/yandex_driving';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextId = 0;

  /// Builds a route.
  static Future<(DrivingSession, Future<DrivingSessionResult>)> requestRoutes({
    required List<RequestPoint> points,
    required DrivingOptions drivingOptions
  }) async {
    final session = await _initSession();

    return (session, session._requestRoutes(points: points, drivingOptions: drivingOptions));
  }

  /// Initialize session on native side for further use
  static Future<DrivingSession> _initSession() async {
    final id = _nextId++;

    await _channel.invokeMethod('initSession', { 'id': id });

    return DrivingSession._(id: id);
  }
}
