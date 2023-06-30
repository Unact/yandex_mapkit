part of yandex_mapkit;

class BicycleSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_bicycle_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;
  bool _isClosed = false;

  /// Has the current session been closed
  bool get isClosed => _isClosed;

  BicycleSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Retries current session
  ///
  /// After [BicycleSession.close] has been called, all subsequent calls will return a [BicycleSessionException]
  Future<void> retry() async {
    if (_isClosed) {
      throw BicycleSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('retry');
  }

  /// Cancels current session
  ///
  /// After [BicycleSession.close] has been called, all subsequent calls will return a [BicycleSessionException]
  Future<void> cancel() async {
    if (_isClosed) {
      throw BicycleSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Closes current session
  ///
  /// After first call, all subsequent calls will return a [BicycleSessionException]
  Future<void> close() async {
    if (_isClosed) {
      throw BicycleSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('close');

    _isClosed = true;
  }
}

class BicycleSessionException extends SessionException {
  BicycleSessionException._(String message) : super._(message);
}

/// Result of a request to build routes
/// If any error has occured then [routes] will be empty, otherwise [error] will be empty
class BicycleSessionResult {
  /// Calculated routes
  final List<BicycleRoute>? routes;

  /// Error message
  final String? error;

  BicycleSessionResult._(this.routes, this.error);

  factory BicycleSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return BicycleSessionResult._(
      json['routes']?.map<BicycleRoute>((dynamic route) => BicycleRoute._fromJson(route)).toList(),
      json['error']
    );
  }
}

/// Object containing the result of a route building request and
/// a [session] object for further working with newly made request
class BicycleResultWithSession {
  /// Created session
  BicycleSession session;

  /// Request result
  Future<BicycleSessionResult> result;

  BicycleResultWithSession._({
    required this.session,
    required this.result
  });
}
