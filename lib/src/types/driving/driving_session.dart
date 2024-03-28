part of '../../../yandex_mapkit.dart';

class DrivingSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_driving_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;

  DrivingSession._({required this.id}) :
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

  Future<DrivingSessionResult> _requestRoutes({
    required List<RequestPoint> points,
    required DrivingOptions drivingOptions
  }) async {
    final params = <String, dynamic>{
      'points': points.map((RequestPoint requestPoint) => requestPoint.toJson()).toList(),
      'drivingOptions': drivingOptions.toJson()
    };

    final result = await _methodChannel.invokeMethod('requestRoutes', params);

    return DrivingSessionResult._fromJson(result);
  }
}

/// Result of a request to build routes
/// If any error has occured then [routes] will be empty, otherwise [error] will be empty
class DrivingSessionResult {
  /// Calculated routes
  final List<DrivingRoute>? routes;

  /// Error message
  final String? error;

  DrivingSessionResult._(this.routes, this.error);

  factory DrivingSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return DrivingSessionResult._(
      json['routes']?.map<DrivingRoute>((dynamic route) => DrivingRoute._fromJson(route)).toList(),
      json['error']
    );
  }
}
