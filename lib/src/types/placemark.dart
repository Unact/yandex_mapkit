part of yandex_mapkit;

class Placemark {
  Placemark({
    required this.point,
    this.style = const PlacemarkStyle(),
    this.onTap,
  });

  final Point point;
  final PlacemarkStyle style;
  final TapCallback<Placemark, Point>? onTap;
}
