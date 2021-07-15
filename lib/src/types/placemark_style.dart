part of yandex_mapkit;

class PlacemarkStyle extends Equatable {

  static const double kScale = 1.0;
  static const double kZIndex = 0.0;
  static const Point kIconAnchor = Point(latitude: 0.5, longitude: 0.5);

  final Point         anchor;
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
        'x': anchor.latitude,
        'y': anchor.longitude,
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
          'x': tappableArea!.min.latitude,
          'y': tappableArea!.min.longitude,
        },
        'max': {
          'x': tappableArea!.max.latitude,
          'y': tappableArea!.max.longitude,
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
