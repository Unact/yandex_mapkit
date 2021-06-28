part of yandex_mapkit;

class Polyline extends Equatable {
  const Polyline({
    required this.coordinates,
    this.style = const PolylineStyle(),
  });

  final List<Point> coordinates;

  final PolylineStyle style;

  @override
  List<Object> get props => <Object>[
    coordinates,
    style
  ];

  @override
  bool get stringify => true;
}
