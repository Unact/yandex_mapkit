part of yandex_mapkit;

class DrivingSession {
  const DrivingSession(this.result, this.cancelSession);

  final Future<DrivingSessionResult> result;

  final CancelDrivingSessionCallback cancelSession;
}

class DrivingSessionResult {
  final List<DrivingRoute>? routes;
  final String? error;

  DrivingSessionResult(this.routes, this.error);
}
