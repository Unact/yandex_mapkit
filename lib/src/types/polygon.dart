part of yandex_mapkit;

class Polygon extends Equatable implements Tappable {
  const Polygon({
    required this.key,
    required this.outerRingCoordinates,
    this.innerRingsCoordinates = const <List<Point>>[],
    this.style = const PolygonStyle(),
    this.onTap,
  });

  final List<Point> outerRingCoordinates;
  final List<List<Point>> innerRingsCoordinates;
  final PolygonStyle style;
  @override
  final ArgumentCallback<Tappable, Point>? onTap;
  @override
  final String key;

  @override
  List<Object> get props => <Object>[
    outerRingCoordinates,
    innerRingsCoordinates,
    style
  ];

  @override
  bool get stringify => true;

}
