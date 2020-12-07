part of yandex_mapkit;

class Placemark extends PlacemarkStyle {
  Placemark({
    @required this.point,
    this.onTap = _kOnTap,
    double scale = PlacemarkStyle.kScale,
    double zIndex = PlacemarkStyle.kZIndex,
    Point iconAnchor = PlacemarkStyle.kIconAnchor,
    double opacity = PlacemarkStyle.kOpacity,
    bool isDraggable = false,
    String iconName,
    RotationType rotationType,
    double direction = PlacemarkStyle.kDirection,
    Uint8List rawImageData,
  }) : super(
          scale: scale,
          zIndex: zIndex,
          iconAnchor: iconAnchor,
          opacity: opacity,
          isDraggable: isDraggable,
          iconName: iconName,
          rotationType: rotationType,
          direction: direction,
          rawImageData: rawImageData,
        );

  final Point point;
  final ArgumentCallback<Point> onTap;

  static void _kOnTap(Point point) => () {};
}
