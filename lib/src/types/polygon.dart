part of yandex_mapkit;

class Polygon extends Equatable{
  const Polygon({
    required this.outerRingCoordinates,
    this.innerRingsCoordinates = const <List<Point>>[],
    this.style = const PolygonStyle()
  });

  final List<Point> outerRingCoordinates;
  final List<List<Point>> innerRingsCoordinates;
  final PolygonStyle style;

  @override
  List<Object> get props => <Object>[
    outerRingCoordinates,
    innerRingsCoordinates,
    style
  ];

  @override
  bool get stringify => true;
}
