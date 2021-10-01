part of yandex_mapkit;

class Polygon extends MapObject {
  Polygon({
    required this.outerRingCoordinates,
    this.innerRingsCoordinates = const <List<Point>>[],
    this.isGeodesic = false,
    this.style = const PolygonStyle(),
    double zIndex = 0.0,
    TapCallback<Polygon>? onTap
  }) : super._(zIndex, onTap);

  final List<Point> outerRingCoordinates;
  final List<List<Point>> innerRingsCoordinates;
  final bool isGeodesic;
  final PolygonStyle style;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'outerRingCoordinates': outerRingCoordinates.map((Point p) => p.toJson()).toList(),
      'innerRingsCoordinates': innerRingsCoordinates.map(
        (List<Point> list) => list.map((Point p) => p.toJson()).toList()
      ).toList(),
      'isGeodesic': isGeodesic,
      'style': style.toJson(),
      'zIndex': zIndex
    };
  }
}

class PolygonStyle extends Equatable {
  const PolygonStyle({
    this.strokeWidth = 1,
    this.strokeColor = const Color(0xFF0066FF),
    this.fillColor = const Color(0x00000000),
  });

  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  @override
  List<Object> get props => <Object>[
    fillColor,
    strokeColor,
    strokeWidth,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'strokeColor': strokeColor.value,
      'strokeWidth': strokeWidth,
      'fillColor': fillColor.value,
    };
  }
}
