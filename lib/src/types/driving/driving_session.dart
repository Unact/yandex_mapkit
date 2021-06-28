part of yandex_mapkit;

class DrivingSession {
  const DrivingSession(this.routes, this.cancelSession);

  final Future<List<DrivingRoute>> routes;
  final CancelDrivingSessionCallback cancelSession;
}
