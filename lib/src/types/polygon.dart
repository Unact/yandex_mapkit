part of yandex_mapkit;

class Polygon extends Equatable implements Tappable {
  const Polygon({
    this.keyValue,
    required this.outerRingCoordinates,
    this.innerRingsCoordinates = const <List<Point>>[],
    this.style = const PolygonStyle(),
    this.onTap,
  });

  final List<Point> outerRingCoordinates;
  final List<List<Point>> innerRingsCoordinates;
  final PolygonStyle style;
  @override
  final TapCallback<Tappable, Point>? onTap;
  final String? keyValue;

  @override
  String getKey() {
    return keyValue != null ? keyValue! : hashCode.toString();
  }


  @override
  List<Object> get props => <Object>[
    outerRingCoordinates,
    innerRingsCoordinates,
    style
  ];

  @override
  bool get stringify => true;

}
