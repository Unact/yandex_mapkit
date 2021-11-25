part of yandex_mapkit;

enum RotationType {
  noRotation,
  rotate
}

/// A placemark to be displayed on [YandexMap] at a specific point
class Placemark extends Equatable implements MapObject {
  const Placemark({
    required this.mapId,
    required this.point,
    this.style = const PlacemarkStyle(),
    this.zIndex = 0.0,
    this.onTap,
    this.isVisible = true
  });

  final Point point;
  final PlacemarkStyle style;
  final double zIndex;
  final TapCallback<Placemark>? onTap;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  Placemark copyWith({
    Point? point,
    PlacemarkStyle? style,
    double? zIndex,
    TapCallback<Placemark>? onTap,
    bool? isVisible
  }) {
    return Placemark(
      mapId: mapId,
      point: point ?? this.point,
      style: style ?? this.style,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      isVisible: isVisible ?? this.isVisible
    );
  }

  @override
  final MapObjectId mapId;

  @override
  Placemark clone() => copyWith();

  @override
  Placemark dup(MapObjectId mapId) {
    return Placemark(
      mapId: mapId,
      point: point,
      style: style,
      zIndex: zIndex,
      onTap: onTap,
      isVisible: isVisible
    );
  }

  @override
  void _tap(Point point) {
    if (onTap != null) {
      onTap!(this, point);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': mapId.value,
      'point': point.toJson(),
      'style': style.toJson(),
      'zIndex': zIndex,
      'isVisible': isVisible
    };
  }

  @override
  Map<String, dynamic> _createJson() {
    return toJson()..addAll({
      'type': runtimeType.toString()
    });
  }

  @override
  Map<String, dynamic> _updateJson(MapObject previous) {
    assert(mapId == previous.mapId);

    return toJson()..addAll({
      'type': runtimeType.toString(),
    });
  }

  @override
  Map<String, dynamic> _removeJson() {
    return {
      'id': mapId.value,
      'type': runtimeType.toString()
    };
  }

  @override
  List<Object> get props => <Object>[
    mapId,
    point,
    style,
    zIndex
  ];

  @override
  bool get stringify => true;
}

class PlacemarkStyle extends Equatable {
  const PlacemarkStyle({
    this.icon,
    this.compositeIcon,
    this.opacity = 0.5,
    this.direction = 0,
  });

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
    final json = <String, dynamic>{
      'opacity': opacity,
      'direction': direction,
      'icon': icon?.toJson(),
      'composite': compositeIcon?.map((icon) => icon.toJson()).toList(),
    };

    return json;
  }
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

  PlacemarkIcon.fromIconName({required String iconName, PlacemarkIconStyle style = const PlacemarkIconStyle()}) :
    iconName = iconName, rawImageData = null, style = style;

  PlacemarkIcon.fromRawImageData({required Uint8List rawImageData, PlacemarkIconStyle style = const PlacemarkIconStyle()}) :
    iconName = null, rawImageData = rawImageData, style = style;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'iconName': iconName,
      'rawImageData': rawImageData,
      'style': style.toJson(),
    };

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

  /// Manages visibility of the object on the map.
  final bool          isVisible;
  final double        scale;
  final MapRect?      tappableArea;

  const PlacemarkIconStyle({
    this.anchor       = const Offset(0.5, 0.5),
    this.rotationType = RotationType.noRotation,
    this.zIndex       = 0.0,
    this.flat         = false,
    this.isVisible    = true,
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
      'isVisible': isVisible,
      'scale': scale,
    };

    if (tappableArea != null) {
      json['tappableArea'] = tappableArea!.toJson();
    }

    return json;
  }

  @override
  List<Object?> get props => <Object?>[
    anchor,
    rotationType,
    zIndex,
    flat,
    isVisible,
    scale,
    tappableArea,
  ];

  @override
  bool get stringify => true;
}
