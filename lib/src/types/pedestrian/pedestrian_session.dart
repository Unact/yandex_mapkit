part of yandex_mapkit;


class PedestrianSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_pedestrian_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;
  bool _isClosed = false;

  /// Has the current session been closed
  bool get isClosed => _isClosed;

  PedestrianSession._({required this.id}) :
        _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Retries current session
  ///
  /// After [PedestrianSession.close] has been called, all subsequent calls will return a [PedestrianSessionException]
  Future<void> retry() async {
    if (_isClosed) {
      throw PedestrianSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('retry');
  }

  /// Cancels current session
  ///
  /// After [PedestrianSession.close] has been called, all subsequent calls will return a [PedestrianSessionException]
  Future<void> cancel() async {
    if (_isClosed) {
      throw PedestrianSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Closes current session
  ///
  /// After first call, all subsequent calls will return a [PedestrianSessionException]
  Future<void> close() async {
    if (_isClosed) {
      throw PedestrianSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('close');

    _isClosed = true;
  }
}

class PedestrianSessionException extends SessionException {
  PedestrianSessionException._(String message) : super._(message);
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

/// Object containing the result of a route building request and
/// a [session] object for further working with newly made request
class PedestrianResultWithSession {
  /// Created session
  PedestrianSession session;

  /// Request result
  Future<PedestrianSessionResult> result;

  PedestrianResultWithSession._({
    required this.session,
    required this.result
  });
}
