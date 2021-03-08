import '../../../yandex_mapkit.dart';

class RequestPoint {
  const RequestPoint(this.point, this.requestPointType);

  final Point point;
  final RequestPointType requestPointType;
}

enum RequestPointType { WAYPOINT, VIAPOINT }
