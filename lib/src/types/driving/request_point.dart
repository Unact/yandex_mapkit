part of yandex_mapkit;

class RequestPoint {
  const RequestPoint(this.point, this.requestPointType);

  final Point point;
  final RequestPointType requestPointType;
}

enum RequestPointType { wayPoint, viaPoint }
