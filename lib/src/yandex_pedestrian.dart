part of '../yandex_mapkit.dart';

/// Interface for the Pedestrian router.
class YandexPedestrian {
  static const String _channelName = 'yandex_mapkit/yandex_pedestrian';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextId = 0;

  /// Builds a route.
  static Future<(PedestrianSession, Future<PedestrianSessionResult>)> requestRoutes({
    required List<RequestPoint> points,
    required TimeOptions timeOptions
  }) async {
    final session = await _initSession();

    return (session, session._requestRoutes(points: points, timeOptions: timeOptions));
  }

  /// Initialize session on native side for further use
  static Future<PedestrianSession> _initSession() async {
    final id = _nextId++;

    await _channel.invokeMethod('initSession', { 'id': id });

    return PedestrianSession._(id: id);
  }
}
