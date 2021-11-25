part of yandex_mapkit;

/// A circle to be displayed on [YandexMap].
class Circle extends Equatable implements MapObject<Circle> {
  const Circle({
    required this.mapId,
    required this.center,
    required this.radius,
    this.isGeodesic = false,
    this.style = const CircleStyle(),
    this.zIndex = 0.0,
    this.onTap,
    this.isVisible = true
  });

  final Point center;
  final double radius;
  final bool isGeodesic;
  final CircleStyle style;
  final double zIndex;
  final TapCallback<Circle>? onTap;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  Circle copyWith({
    Point? center,
    double? radius,
    bool? isGeodesic,
    CircleStyle? style,
    double? zIndex,
    TapCallback<Circle>? onTap,
    bool? isVisible
  }) {
    return Circle(
      mapId: mapId,
      center: center ?? this.center,
      radius: radius ?? this.radius,
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
  Circle clone() => copyWith();

  @override
  Circle dup(MapObjectId mapId) {
    return Circle(
      mapId: mapId,
      center: center,
      radius: radius,
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
    return {
      'id': mapId.value,
      'center': center.toJson(),
      'radius': radius,
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
    center,
    radius,
    isGeodesic,
    style,
    zIndex
  ];

  @override
  bool get stringify => true;
}

class CircleStyle extends Equatable {
  const CircleStyle({
    this.strokeColor = const Color(0xFF0066FF),
    this.strokeWidth = 5.0,
    this.fillColor = const Color(0xFF64B5F6),
  });

  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;

  @override
  List<Object> get props => <Object>[
    strokeColor,
    strokeWidth,
    fillColor,
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
