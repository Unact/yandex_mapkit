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
  final bool                            isVisible;
  final double?                         zIndex;
  final int?                            collectionId;
  final TapCallback<Placemark, Point>?  onTap;

  /// If both icon and compositeIcon are passed - icon has priority
  Placemark({
    required this.point,
    this.icon,
    this.compositeIcon,
    this.opacity = kOpacity,
    this.isDraggable = false,
    this.direction = kDirection,
    this.isVisible = true,
    this.zIndex,
    this.collectionId,
    this.onTap}) : assert((icon != null || compositeIcon != null), 'Either icon or compositeIcon must be provided');

  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{
      'id': hashCode,
      'point': <String, dynamic>{
        'latitude': point.latitude,
        'longitude': point.longitude,
      },
      'opacity': opacity,
      'isDraggable': isDraggable,
      'direction': direction,
      'isVisible': isVisible,
    };

    if (collectionId != null) {
      json['collectionId'] = collectionId!;
    }

    if (zIndex != null) {
      json['zIndex'] = zIndex!;
    }

    if (icon != null) {

      json['icon'] = <String, dynamic>{};

      if (icon!.iconName != null) {
        json['icon']['iconName'] = icon!.iconName!;
      }

      if (icon!.rawImageData != null) {
        json['icon']['rawImageData'] = icon!.rawImageData!;
      }

      if (icon!.style != null) {
        json['icon']['style'] = icon!.style!.toJson();
      }

    } else {

      json['composite'] = <String, dynamic>{};

      compositeIcon!.forEach((k,v) {

        json['composite'][k] = <String, dynamic>{};

        if (v.iconName != null) {
          json['composite'][k]['iconName'] = v.iconName!;
        }

        if (v.rawImageData != null) {
          json['composite'][k]['rawImageData'] = v.rawImageData!;
        }

        if (v.style != null) {
          json['composite'][k]['style'] = v.style!.toJson();
        }
      });
    }

    return json;
  }
}
