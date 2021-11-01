part of yandex_mapkit;

class Placemark extends MapObject {
  Placemark({
    required this.point,
    required this.style,
    double zIndex = 0.0,
    TapCallback<Placemark>? onTap
  }) : super._(zIndex, onTap);

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
  });

  /// One of two icon types is required.
  /// If both passed icon and compositeIcon are passed - icon has priority.
  final PlacemarkIcon? icon;
  final List<PlacemarkCompositeIcon>? compositeIcon;

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
      json['icon'] = icon!.toJson();
    } else {
      json['composite'] = compositeIcon!.map((icon) => icon.toJson()).toList();
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
  final PlacemarkIconStyle style;

  PlacemarkIcon._({
    this.iconName,
    this.rawImageData,
    this.style = const PlacemarkIconStyle(),
  }) : assert((iconName != null || rawImageData != null), 'Either iconName or rawImageData must be provided');

  PlacemarkIcon.fromIconName({required String iconName, PlacemarkIconStyle style = const PlacemarkIconStyle()}) :
    iconName = iconName, rawImageData = null, style = style;

  PlacemarkIcon.fromRawImageData({required Uint8List rawImageData, PlacemarkIconStyle style = const PlacemarkIconStyle()}) :
    iconName = null, rawImageData = rawImageData, style = style;

  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{};

    if (iconName != null) {
      json['iconName'] = iconName!;
    }

    if (rawImageData != null) {
      json['rawImageData'] = rawImageData!;
    }

    json['style'] = style.toJson();

    return json;
  }
}

class PlacemarkCompositeIcon extends PlacemarkIcon {

  /// Used by MapKit to create a separate layer for each component of composite icon.
  ///
  /// If same name is specified for several icons then layer with that name will be reset with the last one.
  final String layerName;

  PlacemarkCompositeIcon.fromIconName({
    required this.layerName,
    required String iconName,
    PlacemarkIconStyle style = const PlacemarkIconStyle(),
  }) : super.fromIconName(iconName: iconName, style: style);

  PlacemarkCompositeIcon.fromRawImageData({
    required this.layerName,
    required Uint8List rawImageData,
    PlacemarkIconStyle style = const PlacemarkIconStyle(),
  }) : super.fromRawImageData(rawImageData: rawImageData, style: style);

  @override
  Map<String, dynamic> toJson() {

    var json = super.toJson();

    json['layerName'] = layerName;

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
      json['tappableArea'] = tappableArea!.toJson();
    }

    return json;
  }

  @override
  List<Object?> get props {

    var props = <Object?>[
      anchor,
      rotationType,
      zIndex,
      flat,
      visible,
      scale,
      tappableArea,
    ];

    return props;
  }

  @override
  bool get stringify => true;
}