part of yandex_mapkit;


class Placemark {

  static const double kOpacity   = 1;
  static const double kDirection = 0;

  final Point                           point;
  final PlacemarkIcon?                  icon;
  /// Map of iconName => PlacemarkIcon
  final Map<String,PlacemarkIcon>?      compositeIcon;
  final double                          opacity;
  final bool                            isDraggable;
  final double                          direction;
  final TapCallback<Placemark, Point>?  onTap;

  /// If both icon and compositeIcon are passed - icon has priority
  Placemark({
    required this.point,
    this.icon,
    this.compositeIcon,
    this.opacity = kOpacity,
    this.isDraggable = false,
    this.direction = kDirection,
    this.onTap}) : assert((icon != null || compositeIcon != null), 'Either icon or compositeIcon must be provided');
}
