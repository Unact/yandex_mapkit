part of yandex_mapkit;

class PlacemarkStyle {
  PlacemarkStyle({
    this.scale = kScale,
    this.zIndex = kZIndex,
    this.iconAnchor = kIconAnchor,
    this.opacity = kOpacity,
    this.isDraggable = false,
    this.iconName,
    this.rawImageData,
    this.direction = kDirection,
    RotationType rotationType,
  }) : rotationType = rotationType.toString();

  final double scale;
  final double zIndex;
  final Point iconAnchor;
  final double opacity;
  final bool isDraggable;
  final String iconName;
  final String rotationType;
  final double direction;

  /// Provides ability to use binary image data as Placemark icon.
  ///
  /// You can use this property to assign dynamically generated images as [Placemark icon].
  /// For example:
  ///
  /// 1) loaded image from network
  /// http.Response response = await http.get('image.url/image.png');
  /// Placemark(rawImageData: response.bodyBytes);
  ///
  /// 2) or generated image on client side (with Flutter), using dynamic color and icon:
  /// ByteData data = await rootBundle.load(path);
  /// //apply size/color transformations to data, and use it afterwards
  /// Placemark(rawImageData: data.buffer.asUint8List());
  ///
  /// Examples are only sample pseudo code.
  ///
  final Uint8List rawImageData;

  static const double kScale = 1.0;
  static const double kZIndex = 0.0;
  static const Point kIconAnchor = Point(latitude: 0.5, longitude: 0.5);
  static const double kOpacity = 0.5;
  static const double kDirection = 0;
}
