part of yandex_mapkit;

class Placemark extends Equatable {
  Placemark({
    required this.point,
    this.style = const PlacemarkStyle(),
    this.onTap,
  }) : id = _nextIdVal;

  static int _nextId = 0;
  static String get _nextIdVal => '${(Placemark)}_${_nextId++}';

  final String id;
  final Point point;
  final PlacemarkStyle style;
  final TapCallback<Placemark, Point>? onTap;

  @override
  List<Object?> get props => <Object?>[
    id,
    point,
    style,
    onTap
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'point': point.toJson(),
      'style': style.toJson()
    };
  }
}

class PlacemarkStyle extends Equatable {
  const PlacemarkStyle({
    this.scale = 1.0,
    this.zIndex = 0.0,
    this.iconAnchor = const Offset(0.5, 0.5),
    this.opacity = 0.5,
    this.isDraggable = false,
    this.iconName,
    this.rawImageData,
    this.direction = 0,
    this.rotationType = RotationType.noRotation,
  });

  final double scale;
  final double zIndex;
  final Offset iconAnchor;
  final double opacity;
  final bool isDraggable;
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
    zIndex,
    iconAnchor,
    opacity,
    isDraggable,
    rotationType,
    direction
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
      'zIndex' : zIndex,
      'opacity': opacity,
      'isDraggable': isDraggable,
      'iconName': iconName,
      'rawImageData': rawImageData,
      'rotationType': rotationType.index,
      'direction': direction
    };
  }
}

enum RotationType {
  noRotation,
  rotate
}
