part of '../../../yandex_mapkit.dart';

class PedestrianSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_pedestrian_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;

  PedestrianSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Retries current session
  Future<void> retry() async {
    await _methodChannel.invokeMethod<void>('retry');
  }

  /// Cancels current session
  Future<void> cancel() async {
    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Closes current session
  Future<void> close() async {
    await _methodChannel.invokeMethod<void>('close');
  }

  Future<PedestrianSessionResult> _requestRoutes({
    required List<RequestPoint> points,
    required TimeOptions timeOptions
  }) async {
    final params = <String, dynamic>{
      'timeOptions': timeOptions.toJson(),
      'points': points.map((RequestPoint requestPoint) => requestPoint.toJson()).toList(),
    };
    final result = await _methodChannel.invokeMethod('requestRoutes', params);

    return PedestrianSessionResult._fromJson(result);
  }
}

/// Result of a request to build routes
/// If any error has occured then [routes] will be empty, otherwise [error] will be empty
class PedestrianSessionResult {
  /// Calculated routes
  final List<PedestrianRoute>? routes;

  /// Error message
  final String? error;

  PedestrianSessionResult._(this.routes, this.error);

  factory PedestrianSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return PedestrianSessionResult._(
      json['routes']?.map<PedestrianRoute>((dynamic route) => PedestrianRoute._fromJson(route)).toList(),
      json['error']
    );
  }
}
