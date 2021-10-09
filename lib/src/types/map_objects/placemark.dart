part of yandex_mapkit;

class Placemark extends MapObject {

  static const double kOpacity   = 1;
  static const double kDirection = 0;

  /// If both icon and compositeIcon are passed - icon has priority
  Placemark({
    required this.point,
    this.icon,
    this.compositeIcon,
    this.opacity = kOpacity,
    this.isDraggable = false,
    this.direction = kDirection,
    this.isVisible = true,
    double zIndex = 0.0,
    TapCallback<Placemark>? onTap
  }) : assert((icon != null || compositeIcon != null), 'Either icon or compositeIcon must be provided'), super._(zIndex, onTap);

  final Point point;

  /// One of two is possible.
  final PlacemarkIcon?              icon;
  final Map<String,PlacemarkIcon>?  compositeIcon;

  final double  opacity;
  final bool    isDraggable;
  final double  direction;
  final bool    isVisible;

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
      'zIndex': zIndex,
    };

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

class PlacemarkStyle extends Equatable {

  static const double kScale = 1.0;
  static const double kZIndex = 0.0;
  static const Offset kIconAnchor = Offset(0.5, 0.5);

  final Offset        anchor;
  final RotationType  rotationType;
  final double        zIndex;
  final bool          flat;
  final bool          visible;
  final double        scale;
  final Rect?         tappableArea;

  const PlacemarkStyle({
    this.anchor       = kIconAnchor,
    this.rotationType = RotationType.noRotation,
    this.zIndex       = kZIndex,
    this.flat         = false,
    this.visible      = true,
    this.scale        = kScale,
    this.tappableArea,
  });

  Map<String, dynamic> toJson() {

    var json = {
      'anchor': {
        'dx': anchor.dx,
        'dy': anchor.dy,
      },
      'rotationType': rotationType.index,
      'zIndex': zIndex,
      'flat': flat,
      'visible': visible,
      'scale': scale,
    };

    if (tappableArea != null) {
      json['tappableArea'] = {
        'min': {
          'x': tappableArea!.min.dx,
          'y': tappableArea!.min.dy,
        },
        'max': {
          'x': tappableArea!.max.dx,
          'y': tappableArea!.max.dy,
        }
      };
    }

    return json;
  }

  @override
  List<Object> get props {

    var props = <Object>[
      anchor,
      rotationType,
      zIndex,
      flat,
      visible,
      scale,
    ];

    if (tappableArea != null) {
      props.add(tappableArea!);
    }

    return props;
  }

  @override
  bool get stringify => true;
}

enum RotationType {
  noRotation,
  rotate
}

class PlacemarkIcon {

  final String? iconName;
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
  final PlacemarkStyle? style;

  PlacemarkIcon({
    this.iconName,
    this.rawImageData,
    this.style,
  }) : assert((iconName != null || rawImageData != null), 'Either iconName or rawImageData must be provided');

  PlacemarkIcon.fromIconName({required String iconName, PlacemarkStyle? style}) :
    iconName = iconName, rawImageData = null, style = style;

  PlacemarkIcon.fromRawImageData({required Uint8List rawImageData, PlacemarkStyle? style}) :
    iconName = null, rawImageData = rawImageData, style = style;

  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{};

    if (iconName != null) {
      json['iconName'] = iconName!;
    }

    if (rawImageData != null) {
      json['rawImageData'] = rawImageData!;
    }

    if (style != null) {
      json['style'] = style!.toJson();
    }

    return json;
  }
}