part of yandex_mapkit;

class Placemark implements Tappable {
  Placemark({
    this.keyValue,
    required this.point,
    this.style = const PlacemarkStyle(),
    this.onTap,
  });

  final Point point;
  final PlacemarkStyle style;
  @override
  final TapCallback<Tappable, Point>? onTap;
  final String? keyValue;

  @override
  String getKey() {
    return keyValue != null ? keyValue! : hashCode.toString();
  }

}
