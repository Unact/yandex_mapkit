part of yandex_mapkit;

class PlacemarkStyle extends Equatable {
  const PlacemarkStyle({
    this.scale = kScale,
    this.zIndex = kZIndex,
    this.iconAnchor = kIconAnchor,
    this.opacity = kOpacity,
    this.isDraggable = false,
    this.iconName,
    this.rawImageData,
    this.direction = kDirection,
    this.rotationType = RotationType.noRotation,
  });

  final double scale;
  final double zIndex;
  final Point iconAnchor;
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

  static const double kScale = 1.0;
  static const double kZIndex = 0.0;
  static const Point kIconAnchor = Point(latitude: 0.5, longitude: 0.5);
  static const double kOpacity = 0.5;
  static const double kDirection = 0;

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
}
