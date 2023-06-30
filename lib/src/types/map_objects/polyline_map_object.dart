part of yandex_mapkit;

/// Collection of points connected by lines to be displayed on [YandexMap]
class PolylineMapObject extends Equatable implements MapObject {
  const PolylineMapObject({
    required this.mapId,
    required this.polyline,
    this.zIndex = 0.0,
    this.onTap,
    this.consumeTapEvents = false,
    this.isVisible = true,
    this.strokeColor = const Color(0xFF0066FF),
    this.strokeWidth = 5.0,
    this.outlineColor = const Color(0x00000000),
    this.outlineWidth = 0.0,
    this.dashLength = 0.0,
    this.dashOffset = 0.0,
    this.gapLength = 0.0,
    this.turnRadius = 10.0,
    this.arcApproximationStep = 12.0,
    this.gradientLength = 0,
    this.isInnerOutlineEnabled = false
  });

  /// The geometry of the map object.
  final Polyline polyline;

  /// z-order
  ///
  /// Affects:
  /// 1. Rendering order.
  /// 2. Dispatching of UI events(taps and drags are dispatched to objects with higher z-indexes first).
  final double zIndex;

  /// Callback to call when this polyline receives a tap
  final TapCallback<PolylineMapObject>? onTap;

  /// True if the placemark consumes tap events.
  /// If not, the map will propagate tap events to other map objects at the point of tap.
  final bool consumeTapEvents;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  /// Stroke color.
  ///
  /// Setting the stroke color to any transparent color (i.e. RGBA code 0x00000000) effectively disables the stroke.
  final Color strokeColor;

  /// Stroke width in units.
  ///
  /// The size of a unit is equal to the size of a pixel at the current zoom
  /// with the camera position's tilt at 0 and a scale factor of 1
  final double strokeWidth;

  /// Outline color.
  ///
  /// Setting the color to any transparent color (i.e. RGBA code 0x00000000) effectively disables the outline.
  final Color outlineColor;

  /// Outline width in units.
  ///
  /// The size of a unit is equal to the size of a pixel at the current zoom
  /// with the camera position's tilt at 0 and a scale factor of 1
  final double outlineWidth;

  /// Length of a dash in units. Default: 0 (dashing is turned off).
  final double dashLength;

  /// Offset from the start of the polyline to the reference dash in units.
  final double dashOffset;

  /// Length of the gap between two dashes in units. Default: 0 (dashing is turned off).
  final double gapLength;

  /// Maximum radius of a turn. Measured in units.
  final double turnRadius;

  /// Defines step of arc approximation. Smaller values make polyline smoother. Measured in degrees.
  final double arcApproximationStep;

  /// Maximum length (in units) of the gradient from one color to another.
  final double gradientLength;

  /// Enables the inner outline if true (a dark border along the edge of the outline).
  final bool isInnerOutlineEnabled;

  PolylineMapObject copyWith({
    Polyline? polyline,
    double? zIndex,
    TapCallback<PolylineMapObject>? onTap,
    bool? consumeTapEvents,
    bool? isVisible,
    Color? strokeColor,
    double? strokeWidth,
    Color? outlineColor,
    double? outlineWidth,
    double? dashLength,
    double? dashOffset,
    double? gapLength,
    double? turnRadius,
    double? arcApproximationStep,
    double? gradientLength,
    bool? isInnerOutlineEnabled,
  }) {
    return PolylineMapObject(
      mapId: mapId,
      polyline: polyline ?? this.polyline,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      consumeTapEvents: consumeTapEvents ?? this.consumeTapEvents,
      isVisible: isVisible ?? this.isVisible,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      dashLength: dashLength ?? this.dashLength,
      dashOffset: dashOffset ?? this.dashOffset,
      gapLength: gapLength ?? this.gapLength,
      turnRadius: turnRadius ?? this.turnRadius,
      arcApproximationStep: arcApproximationStep ?? this.arcApproximationStep,
      gradientLength: gradientLength ?? this.gradientLength,
      isInnerOutlineEnabled: isInnerOutlineEnabled ?? this.isInnerOutlineEnabled,
    );
  }

  @override
  final MapObjectId mapId;

  @override
  PolylineMapObject clone() => copyWith();

  @override
  PolylineMapObject dup(MapObjectId mapId) {
    return PolylineMapObject(
      mapId: mapId,
      polyline: polyline,
      zIndex: zIndex,
      onTap: onTap,
      consumeTapEvents: consumeTapEvents,
      isVisible: isVisible,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      outlineColor: outlineColor,
      outlineWidth: outlineWidth,
      dashLength: dashLength,
      dashOffset: dashOffset,
      gapLength: gapLength,
      turnRadius: turnRadius,
      arcApproximationStep: arcApproximationStep,
      gradientLength: gradientLength,
      isInnerOutlineEnabled: isInnerOutlineEnabled,
    );
  }

  @override
  void _tap(Point point) {
    if (onTap != null) {
      onTap!(this, point);
    }
  }

  /// Stub for [MapObject]
  /// [PolylineMapObject] does not support drag
  @override
  void _dragStart() {
    throw UnsupportedError;
  }

  /// Stub for [MapObject]
  /// [PolylineMapObject] does not support drag
  @override
  void _drag(Point point) {
    throw UnsupportedError;
  }

  /// Stub for [MapObject]
  /// [PolylineMapObject] does not support drag
  @override
  void _dragEnd() {
    throw UnsupportedError;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': mapId.value,
      'polyline': polyline.toJson(),
      'zIndex': zIndex,
      'consumeTapEvents': consumeTapEvents,
      'isVisible': isVisible,
      'strokeColor': strokeColor.value,
      'strokeWidth': strokeWidth,
      'outlineColor': outlineColor.value,
      'outlineWidth': outlineWidth,
      'dashLength': dashLength,
      'dashOffset': dashOffset,
      'gapLength': gapLength,
      'turnRadius': turnRadius,
      'arcApproximationStep': arcApproximationStep,
      'gradientLength': gradientLength,
      'isInnerOutlineEnabled': isInnerOutlineEnabled,
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
    polyline,
    zIndex,
    consumeTapEvents,
    isVisible,
    strokeColor,
    strokeWidth,
    outlineColor,
    outlineWidth,
    dashLength,
    dashOffset,
    gapLength,
    turnRadius,
    arcApproximationStep,
    gradientLength,
    isInnerOutlineEnabled,
  ];

  @override
  bool get stringify => true;
}
