part of yandex_mapkit;

class Polyline extends Equatable {
  Polyline({
    required this.coordinates,
    this.isGeodesic = false,
    this.style = const PolylineStyle(),
  }) : id = _nextIdVal;

  static int _nextId = 0;
  static String get _nextIdVal => '${(Polyline)}_${_nextId++}';

  final String id;
  final List<Point> coordinates;
  final bool isGeodesic;
  final PolylineStyle style;

  @override
  List<Object> get props => <Object>[
    coordinates,
    isGeodesic,
    style,
  ];

  @override
  bool get stringify => true;

   Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'coordinates': coordinates.map((Point p) => p.toJson()).toList(),
      'isGeodesic': isGeodesic,
      'style': style.toJson(),
    };
  }
}

class PolylineStyle extends Equatable {
  const PolylineStyle({
    this.strokeColor = const Color(0xFF0066FF),
    this.strokeWidth = 5.0,
    this.outlineColor = const Color(0x00000000),
    this.outlineWidth = 0.0,
    this.dashLength = 0.0,
    this.dashOffset = 0.0,
    this.gapLength = 0.0,
  });

  final Color strokeColor;
  final double strokeWidth;

  final Color outlineColor;
  final double outlineWidth;

  final double dashLength;
  final double dashOffset;
  final double gapLength;

  @override
  List<Object> get props => <Object>[
    strokeColor,
    strokeWidth,
    outlineColor,
    outlineWidth,
    dashLength,
    dashOffset,
    gapLength,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'strokeColor': strokeColor.value,
      'strokeWidth': strokeWidth,
      'outlineColor': outlineColor.value,
      'outlineWidth': outlineWidth,
      'dashLength': dashLength,
      'dashOffset': dashOffset,
      'gapLength': gapLength,
    };
  }
}
