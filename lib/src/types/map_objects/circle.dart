part of yandex_mapkit;

/// A circle to be displayed on [YandexMap].
class Circle extends Equatable implements MapObject<Circle> {
  const Circle({
    required this.mapId,
    required this.center,
    required this.radius,
    this.isGeodesic = false,
    this.zIndex = 0.0,
    this.onTap,
    this.isVisible = true,
    this.strokeColor = const Color(0xFF0066FF),
    this.strokeWidth = 5.0,
    this.fillColor = const Color(0xFF64B5F6),
  });

  final Point center;
  final double radius;
  final bool isGeodesic;
  final double zIndex;
  final TapCallback<Circle>? onTap;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  /// Fill color.
  ///
  /// Setting the stroke color to any transparent color (i.e. RGBA code 0x00000000) effectively disables the stroke.
  final Color fillColor;

  /// Stroke color.
  ///
  /// Setting the stroke color to any transparent color (i.e. RGBA code 0x00000000) effectively disables the stroke.
  final Color strokeColor;

  /// Stroke width in units.
  ///
  /// The size of a unit is equal to the size of a pixel at the current zoom
  /// with the camera position's tilt at 0 and a scale factor of 1
  final double strokeWidth;

  Circle copyWith({
    Point? center,
    double? radius,
    bool? isGeodesic,
    double? zIndex,
    TapCallback<Circle>? onTap,
    bool? isVisible,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth
  }) {
    return Circle(
      mapId: mapId,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      isGeodesic: isGeodesic ?? this.isGeodesic,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      isVisible: isVisible ?? this.isVisible,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth
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
      zIndex: zIndex,
      onTap: onTap,
      isVisible: isVisible,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
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
      'zIndex': zIndex,
      'isVisible': isVisible,
      'strokeColor': strokeColor.value,
      'strokeWidth': strokeWidth,
      'fillColor': fillColor.value,
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
    zIndex,
    strokeColor,
    strokeWidth,
    fillColor,
  ];

  @override
  bool get stringify => true;
}
