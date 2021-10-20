part of yandex_mapkit;

class PolygonId extends MapObjectId<Polygon> {
  /// Creates an immutable identifier for a [Polygon].
  const PolygonId(String value) : super(value);
}

/// A polygon to be displayed on [YandexMap]
class Polygon extends Equatable implements MapObject {
  const Polygon({
    required this.polygonId,
    required this.outerRingCoordinates,
    this.innerRingsCoordinates = const <List<Point>>[],
    this.isGeodesic = false,
    this.style = const PolygonStyle(),
    this.zIndex = 0.0,
    this.onTap
  });

  final List<Point> outerRingCoordinates;
  final List<List<Point>> innerRingsCoordinates;
  final bool isGeodesic;
  final PolygonStyle style;
  final double zIndex;
  final TapCallback<Polygon>? onTap;

  final PolygonId polygonId;

  Polygon copyWith({
    List<Point>? outerRingCoordinates,
    List<List<Point>>? innerRingsCoordinates,
    bool? isGeodesic,
    PolygonStyle? style,
    double? zIndex,
    TapCallback<Polygon>? onTap,
  }) {
    return Polygon(
      polygonId: polygonId,
      outerRingCoordinates: outerRingCoordinates ?? this.outerRingCoordinates,
      innerRingsCoordinates: innerRingsCoordinates ?? this.innerRingsCoordinates,
      isGeodesic: isGeodesic ?? this.isGeodesic,
      style: style ?? this.style,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap
    );
  }

  @override
  PolygonId get mapId => polygonId;

  @override
  Polygon clone() => copyWith();

  @override
  void _tap(Point point) {
    if (onTap != null) {
      onTap!(this, point);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': mapId.value,
      'outerRingCoordinates': outerRingCoordinates.map((Point p) => p.toJson()).toList(),
      'innerRingsCoordinates': innerRingsCoordinates.map(
        (List<Point> list) => list.map((Point p) => p.toJson()).toList()
      ).toList(),
      'isGeodesic': isGeodesic,
      'style': style.toJson(),
      'zIndex': zIndex
    };
  }

  @override
  Map<String, dynamic> _createJson() {
    return toJson()..addAll({
      'type': runtimeType.toString()
    });
  }

  @override
  Map<String, dynamic> _updateJson(MapObject previous) {
    assert(mapId == previous.mapId);

    return toJson()..addAll({
      'type': runtimeType.toString(),
    });
  }

  @override
  Map<String, dynamic> _removeJson() {
    return {
      'id': mapId.value,
      'type': runtimeType.toString()
    };
  }

  @override
  List<Object> get props => <Object>[
    polygonId,
    outerRingCoordinates,
    innerRingsCoordinates,
    isGeodesic,
    style,
    zIndex
  ];

  @override
  bool get stringify => true;
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
