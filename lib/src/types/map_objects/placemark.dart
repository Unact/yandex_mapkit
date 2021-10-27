part of yandex_mapkit;

/// A placemark to be displayed on [YandexMap] at a specific point
class Placemark extends Equatable implements MapObject {
  const Placemark({
    required this.mapId,
    required this.point,
    this.style = const PlacemarkStyle(),
    this.isDraggable = false,
    this.zIndex = 0.0,
    this.onTap
  });

  final Point point;
  final bool isDraggable;
  final PlacemarkStyle style;
  final double zIndex;
  final TapCallback<Placemark>? onTap;

  Placemark copyWith({
    Point? point,
    PlacemarkStyle? style,
    bool? isDraggable,
    double? zIndex,
    TapCallback<Placemark>? onTap,
  }) {
    return Placemark(
      mapId: mapId,
      point: point ?? this.point,
      style: style ?? this.style,
      isDraggable: isDraggable ?? this.isDraggable,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap
    );
  }

  @override
  final MapObjectId mapId;

  @override
  Placemark clone() => copyWith();

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
      'point': point.toJson(),
      'isDraggable': isDraggable,
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
    mapId,
    point,
    style,
    isDraggable,
    zIndex
  ];

  @override
  bool get stringify => true;
}

class PlacemarkStyle extends Equatable {
  const PlacemarkStyle({
    this.scale = 1.0,
    this.iconAnchor = const Offset(0.5, 0.5),
    this.opacity = 0.5,
    this.iconName,
    this.rawImageData,
    this.direction = 0,
    this.rotationType = RotationType.noRotation,
  });

  final double scale;
  final Offset iconAnchor;
  final double opacity;
  final String? iconName;
  final RotationType rotationType;
  final double direction;

  /// Provides ability to use binary image data as Placemark icon.
  ///
  /// You can use this property to assign dynamically generated images as [Placemark icon].
  /// For example:
  ///
  /// 1) Loaded image from network
  /// http.Response response = await http.get('image.url/image.png');
  /// PlacemarkStyle(rawImageData: response.bodyBytes);
  ///
  /// 2) Generated image on client side (with Flutter), using dynamic color and icon:
  /// ByteData data = await rootBundle.load(path);
  /// //apply size/color transformations to data, and use it afterwards
  /// PlacemarkStyle(rawImageData: data.buffer.asUint8List());
  ///
  final Uint8List? rawImageData;

  @override
  List<Object> get props => <Object>[
    scale,
    iconAnchor,
    opacity,
    rotationType,
    direction,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'iconAnchor': {
        'dx': iconAnchor.dx,
        'dy': iconAnchor.dy
      },
      'scale': scale,
      'opacity': opacity,
      'iconName': iconName,
      'rawImageData': rawImageData,
      'rotationType': rotationType.index,
      'direction': direction,
    };
  }
}

enum RotationType {
  noRotation,
  rotate
}
