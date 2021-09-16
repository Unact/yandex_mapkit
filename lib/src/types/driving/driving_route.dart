part of yandex_mapkit;

class DrivingRoute {
  const DrivingRoute(this.geometry, this.metadata);

  final List<Point> geometry;
  final DrivingSectionMetadata metadata;
}
