part of yandex_mapkit;

/// Collection of points connected by lines to be displayed on [YandexMap]
class Polyline extends Equatable implements MapObject {
  const Polyline({
    required this.mapId,
    required this.coordinates,
    this.isGeodesic = false,
    this.style = const PolylineStyle(),
    this.zIndex = 0.0,
    this.onTap,
    this.isVisible = true
  });

  final List<Point> coordinates;
  final bool isGeodesic;
  final PolylineStyle style;
  final double zIndex;
  final TapCallback<Polyline>? onTap;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  Polyline copyWith({
    List<Point>? coordinates,
    bool? isGeodesic,
    PolylineStyle? style,
    double? zIndex,
    TapCallback<Polyline>? onTap,
    bool? isVisible
  }) {
    return Polyline(
      mapId: mapId,
      coordinates: coordinates ?? this.coordinates,
      isGeodesic: isGeodesic ?? this.isGeodesic,
      style: style ?? this.style,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      isVisible: isVisible ?? this.isVisible
    );
  }

  @override
  final MapObjectId mapId;

  @override
  Polyline clone() => copyWith();

  @override
  Polyline dup(MapObjectId mapId) {
    return Polyline(
      mapId: mapId,
      coordinates: coordinates,
      isGeodesic: isGeodesic,
      style: style,
      zIndex: zIndex,
      onTap: onTap,
      isVisible: isVisible
    );
  }

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
      'coordinates': coordinates.map((Point p) => p.toJson()).toList(),
      'isGeodesic': isGeodesic,
      'style': style.toJson(),
      'zIndex': zIndex,
      'isVisible': isVisible
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
    mapId,
    coordinates,
    isGeodesic,
    style,
    zIndex
  ];

  @override
  bool get stringify => true;
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
