part of yandex_mapkit;

class Placemark extends MapObject {
  Placemark({
    required this.point,
    required this.style,
    double zIndex = 0.0,
    bool isVisible = true,
    bool isDraggable = false,
    TapCallback<Placemark>? onTap
  }) : super._(zIndex, isVisible, isDraggable, onTap);

  final Point point;
  final PlacemarkStyle style;

  @override
  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{
      'id': id,
      'point': <String, dynamic>{
        'latitude': point.latitude,
        'longitude': point.longitude,
      },
      'zIndex': zIndex,
      'isVisible': isVisible,
      'isDraggable': isDraggable,
      'style': style.toJson(),
    };

    return json;
  }
}

class PlacemarkStyle extends Equatable {
  const PlacemarkStyle({
    this.icon,
    this.compositeIcon,
    this.opacity = 0.5,
    this.direction = 0,
  }) : assert((icon != null || compositeIcon != null), 'Either icon or compositeIcon must be provided');

  /// One of two icon types is required.
  /// If both passed icon and compositeIcon are passed - icon has priority.
  final PlacemarkIcon?              icon;
  final Map<String,PlacemarkIcon>?  compositeIcon;

  final double  opacity;
  final double  direction;

  @override
  List<Object?> get props => <Object?>[
    icon,
    compositeIcon,
    opacity,
    direction,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'opacity': opacity,
      'direction': direction,
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
  final PlacemarkIconStyle? style;

  PlacemarkIcon({
    this.iconName,
    this.rawImageData,
    this.style,
  }) : assert((iconName != null || rawImageData != null), 'Either iconName or rawImageData must be provided');

  PlacemarkIcon.fromIconName({required String iconName, PlacemarkIconStyle? style}) :
    iconName = iconName, rawImageData = null, style = style;

  PlacemarkIcon.fromRawImageData({required Uint8List rawImageData, PlacemarkIconStyle? style}) :
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

class PlacemarkIconStyle extends Equatable {
  final Offset        anchor;
  final RotationType  rotationType;
  final double        zIndex;
  final bool          flat;
  final bool          visible;
  final double        scale;
  final Rect?         tappableArea;

  const PlacemarkIconStyle({
    this.anchor       = const Offset(0.5, 0.5),
    this.rotationType = RotationType.noRotation,
    this.zIndex       = 0.0,
    this.flat         = false,
    this.visible      = true,
    this.scale        = 1.0,
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