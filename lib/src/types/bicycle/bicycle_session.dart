part of '../../../yandex_mapkit.dart';

class BicycleSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_bicycle_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;

  BicycleSession._({required this.id}) :
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

  Future<BicycleSessionResult> _requestRoutes({
    required List<RequestPoint> points,
    required FitnessOptions fitnessOptions,
    required TimeOptions timeOptions
  }) async {
    final params = <String, dynamic>{
      'timeOptions': timeOptions.toJson(),
      'fitnessOptions': fitnessOptions.toJson(),
      'points': points.map((RequestPoint requestPoint) => requestPoint.toJson()).toList(),
    };
    final result = await _methodChannel.invokeMethod('requestRoutes', params);

    return BicycleSessionResult._fromJson(result);
  }
}

/// Result of a request to build routes
/// If any error has occured then [routes] will be empty, otherwise [error] will be empty
class BicycleSessionResult {
  /// Calculated routes
  final List<MasstransitRoute>? routes;

  /// Error message
  final String? error;

  BicycleSessionResult._(this.routes, this.error);

  factory BicycleSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return BicycleSessionResult._(
      json['routes']?.map<MasstransitRoute>((dynamic route) => MasstransitRoute._fromJson(route)).toList(),
      json['error']
    );
  }
}
