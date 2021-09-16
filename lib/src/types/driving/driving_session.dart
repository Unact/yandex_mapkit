part of yandex_mapkit;

class DrivingSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_driving_session_';
  final MethodChannel _methodChannel;

  final int id;
  bool _isClosed = false;

  DrivingSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Retries current session.
  ///
  /// After [DrivingSession.close] has been called, all subsequent calls will return a [DrivingSessionException]
  Future<void> retry() async {
    if (_isClosed) {
      throw DrivingSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('retry');
  }

  /// Cancels current session.
  ///
  /// After [DrivingSession.close] has been called, all subsequent calls will return a [DrivingSessionException]
  Future<void> cancel() async {
    if (_isClosed) {
      throw DrivingSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Closes current session.
  ///
  /// After first call, all subsequent calls will return a [DrivingSessionException]
  Future<void> close() async {
    if (_isClosed) {
      throw DrivingSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('close');

    _isClosed = true;
  }
}

class DrivingSessionException extends SessionException {
  DrivingSessionException._(String message) : super._(message);
}
class DrivingSessionResult {
  final List<DrivingRoute>? routes;
  final String? error;

  DrivingSessionResult._(this.routes, this.error);

  factory DrivingSessionResult.fromJson(Map<dynamic, dynamic> json) {
    String? error = json['error'];
    List<dynamic>? resultRoutes = json['routes'];
    var routes = resultRoutes?.map((dynamic route) {
      final List<dynamic> resultPoints = route['geometry'];
      final points = resultPoints.map((dynamic resultPoint) => Point.fromJson(resultPoint)).toList();
      final dynamic weight = route['metadata']['weight'];
      final metadata = DrivingSectionMetadata._(
        DrivingWeight._(
          LocalizedValue(
            weight['time']['value'],
            weight['time']['text'],
          ),
          LocalizedValue(
            weight['timeWithTraffic']['value'],
            weight['timeWithTraffic']['text'],
          ),
          LocalizedValue(
            weight['distance']['value'],
            weight['distance']['text'],
          ),
        ),
      );

      return DrivingRoute._(points, metadata);
    }).toList();

    return DrivingSessionResult._(routes, error);
  }
}

class DrivingResultWithSession {
  DrivingSession session;
  Future<DrivingSessionResult> result;

  DrivingResultWithSession._({
    required this.session,
    required this.result
  });
}
