part of yandex_mapkit;

class Polygon extends Equatable{
  const Polygon({
    required this.coordinates,
    this.style = const PolygonStyle()
  });

  final List<Point> coordinates;
  final PolygonStyle style;

  @override
  List<Object> get props => <Object>[
    coordinates,
    style
  ];

  @override
  bool get stringify => true;
}
