part of yandex_mapkit;

/// A placemark to be displayed on [YandexMap] at a specific point
class PlacemarkMapObject extends Equatable implements MapObject {
  const PlacemarkMapObject({
    required this.mapId,
    required this.point,
    this.zIndex = 0.0,
    this.onTap,
    this.onDragStart,
    this.onDrag,
    this.onDragEnd,
    this.consumeTapEvents = false,
    this.isVisible = true,
    this.isDraggable = false,
    this.icon,
    this.opacity = 0.5,
    this.direction = 0,
  });

  /// The geometry of the map object.
  final Point point;

  /// z-order
  ///
  /// Affects:
  /// 1. Rendering order.
  /// 2. Dispatching of UI events(taps and drags are dispatched to objects with higher z-indexes first).
  final double zIndex;

  /// Callback to call when this placemark receives a tap
  final TapCallback<PlacemarkMapObject>? onTap;

  /// True if the placemark consumes tap events.
  /// If not, the map will propagate tap events to other map objects at the point of tap.
  final bool consumeTapEvents;

  /// Raised when dragging mode is active for the given map object.
  final DragStartCallback<PlacemarkMapObject>? onDragStart;

  /// Raised when the user is moving a finger and the map object follows it.
  final DragCallback<PlacemarkMapObject>? onDrag;

  /// Raised when the user released the tap.
  final DragEndCallback<PlacemarkMapObject>? onDragEnd;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  /// Manages if map object can be dragged by the user.
  final bool isDraggable;

  /// Visual appearance of [PlacemarkMapObject] on the map.
  final PlacemarkIcon? icon;

  /// Opacity multiplicator for the placemark content.
  /// Values below 0 will be set to 0.
  final double opacity;

  /// Angle between the direction of an object and the direction to north.
  /// Measured in degrees.
  final double direction;

  PlacemarkMapObject copyWith({
    Point? point,
    double? zIndex,
    TapCallback<PlacemarkMapObject>? onTap,
    DragStartCallback<PlacemarkMapObject>? onDragStart,
    DragCallback<PlacemarkMapObject>? onDrag,
    DragEndCallback<PlacemarkMapObject>? onDragEnd,
    bool? consumeTapEvents,
    bool? isVisible,
    bool? isDraggable,
    PlacemarkIcon? icon,
    double? opacity,
    double? direction,
  }) {
    return PlacemarkMapObject(
      mapId: mapId,
      point: point ?? this.point,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      onDragStart: onDragStart ?? this.onDragStart,
      onDrag: onDrag ?? this.onDrag,
      onDragEnd: onDragEnd ?? this.onDragEnd,
      consumeTapEvents: consumeTapEvents ?? this.consumeTapEvents,
      isVisible: isVisible ?? this.isVisible,
      isDraggable: isDraggable ?? this.isDraggable,
      icon: icon ?? this.icon,
      opacity: opacity ?? this.opacity,
      direction: direction ?? this.direction
    );
  }

  @override
  final MapObjectId mapId;

  @override
  PlacemarkMapObject clone() => copyWith();

  @override
  PlacemarkMapObject dup(MapObjectId mapId) {
    return PlacemarkMapObject(
      mapId: mapId,
      point: point,
      zIndex: zIndex,
      onTap: onTap,
      onDragStart: onDragStart,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
      consumeTapEvents: consumeTapEvents,
      isVisible: isVisible,
      isDraggable: isDraggable,
      icon: icon,
      opacity: opacity,
      direction: direction
    );
  }

  @override
  void _tap(Point point) {
    if (onTap != null) {
      onTap!(this, point);
    }
  }

  @override
  void _dragStart() {
    if (onDragStart != null) {
      onDragStart!(this);
    }
  }

  @override
  void _drag(Point point) {
    if (onDrag != null) {
      onDrag!(this, point);
    }
  }

  @override
  void _dragEnd() {
    if (onDragEnd != null) {
      onDragEnd!(this);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': mapId.value,
      'point': point.toJson(),
      'zIndex': zIndex,
      'consumeTapEvents': consumeTapEvents,
      'isVisible': isVisible,
      'isDraggable': isDraggable,
      'opacity': opacity,
      'direction': direction,
      'icon': icon?.toJson()
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
  List<Object?> get props => <Object?>[
    mapId,
    point,
    zIndex,
    consumeTapEvents,
    isVisible,
    isDraggable,
    opacity,
    direction,
    icon
  ];

  @override
  bool get stringify => true;
}

/// Visual icon of a single [PlacemarkMapObject]
class PlacemarkIcon extends Equatable {
  /// Serialized information about how to visually show a single [PlacemarkMapObject]
  final Map<String, dynamic> _json;

  const PlacemarkIcon._(this._json);

  /// Used to describe a set of icons to be used as part of a single icon to represent a [PlacemarkMapObject] on the map.
  factory PlacemarkIcon.composite(List<PlacemarkCompositeIconItem> iconParts) {
    return PlacemarkIcon._({
      'type': 'composite',
      'iconParts': iconParts.map((e) => e.toJson()).toList()
    });
  }

  /// Used to describe a single icon to represent a [PlacemarkMapObject] on the map.
  factory PlacemarkIcon.single(PlacemarkIconStyle style) {
    return PlacemarkIcon._({
      'type': 'single',
      'style': style.toJson()
    });
  }

  Map<String, dynamic> toJson() => _json;

  @override
  List<Object> get props => <Object>[
    _json
  ];

  @override
  bool get stringify => true;
}

/// Visual icon of an icon to be used to visually show a [PlacemarkMapObject]
class PlacemarkIconStyle extends Equatable {
  /// Asset name to use as Placemark icon
  final BitmapDescriptor image;

  /// An anchor is used to alter image placement.
  /// Normalized: (0.0f, 0.0f) denotes the top left image corner; (1.0f, 1.0f) denotes bottom right.
  final Offset anchor;

  /// Icon rotation type.
  final RotationType rotationType;

  /// Z-index of the icon, relative to the placemark's z-index.
  final double zIndex;

  /// If true, the icon is displayed on the map surface.
  /// If false, the icon is displayed on the screen surface.
  final bool isFlat;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  /// Scale of the icon.
  final double scale;

  /// Tappable area on the icon.
  /// Coordinates are measured the same way as anchor coordinates.
  /// If rect is empty or invalid, the icon will not process taps.
  /// By default, icons process all taps.
  final MapRect? tappableArea;

  /// Creates an icon to be used to represent a [PlacemarkMapObject] on the map.
  const PlacemarkIconStyle({
    required this.image,
    this.anchor = const Offset(0.5, 0.5),
    this.rotationType = RotationType.noRotation,
    this.zIndex = 0,
    this.isFlat = false,
    this.isVisible = true,
    this.scale = 1,
    this.tappableArea
  });

  Map<String, dynamic> toJson() {
    return {
      'image': image.toJson(),
      'anchor': {
        'dx': anchor.dx,
        'dy': anchor.dy,
      },
      'rotationType': rotationType.index,
      'zIndex': zIndex,
      'isFlat': isFlat,
      'isVisible': isVisible,
      'scale': scale,
      'tappableArea': tappableArea?.toJson()
    };
  }

  @override
  List<Object?> get props => <Object?>[
    anchor,
    rotationType,
    zIndex,
    isFlat,
    isVisible,
    scale,
    tappableArea
  ];

  @override
  bool get stringify => true;
}


/// A part of a composite icon to visually show a [PlacemarkMapObject] icon
class PlacemarkCompositeIconItem extends Equatable {
  /// Base icon to use for composition
  final PlacemarkIconStyle style;

  /// Creates a separate named layer for each component of composite icon.
  /// This is mainly used to denote layer name for composite icons.
  ///
  /// If same name is specified for several icons then layer with that name will be reset with the last one.
  final String name;

  /// Creates an icon to be used as part of a single icon to represent a [PlacemarkMapObject] on the map.
  const PlacemarkCompositeIconItem({
    required this.style,
    required this.name
  });

  Map<String, dynamic> toJson() {
    return {
      'style': style.toJson(),
      'name': name
    };
  }

  @override
  List<Object> get props => <Object>[
    style,
    name
  ];

  @override
  bool get stringify => true;
}

/// [PlacemarkIconStyle] rotation types
enum RotationType {
  noRotation,
  rotate
}
