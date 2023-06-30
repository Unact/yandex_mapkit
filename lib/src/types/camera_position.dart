part of yandex_mapkit;

/// The position of the camera.
class CameraPosition extends Equatable {
  const CameraPosition({
    required this.target,
    this.zoom = 15.0,
    this.azimuth = 0.0,
    this.tilt = 0.0,
  });

  /// The point the camera is looking at.
  final Point target;

  /// Zoom level. 0 corresponds to the whole world displayed in a single tile.
  final double zoom;

  /// Angle between north and the direction of interest on the map plane, in degrees in the range (0, 360).
  final double azimuth;

  /// Camera tilt in degrees. 0 means vertical downward.
  final double tilt;

  /// Returns a copy of [CameraPosition] whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  CameraPosition copyWith({
    Point? target,
    double? zoom,
    double? azimuth,
    double? tilt
  }) {
    return CameraPosition(
      target: target ?? this.target,
      zoom: zoom ?? this.zoom,
      azimuth: azimuth ?? this.azimuth,
      tilt: tilt ?? this.tilt
    );
  }

  @override
  List<Object> get props => <Object>[
    target,
    zoom,
    azimuth,
    tilt
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'target': target.toJson(),
      'zoom': zoom,
      'azimuth': azimuth,
      'tilt': tilt
    };
  }

  factory CameraPosition._fromJson(Map<dynamic, dynamic> json) {
    return CameraPosition(
      target: Point._fromJson(json['target']),
      zoom: json['zoom'],
      azimuth: json['azimuth'],
      tilt: json['tilt'],
    );
  }
}

enum CameraUpdateReason {
  gestures,
  application
}

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
class CameraUpdate {
  CameraUpdate._(this._json);

  /// Returns a camera update that moves the camera to the specified position.
  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return CameraUpdate._({
      'type': 'newCameraPosition',
      'params': {
        'cameraPosition': cameraPosition.toJson()
      }
    });
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location in the custom focus rect.
  /// If [focusRect] is null then the current focus rect is used.
  static CameraUpdate newBounds(BoundingBox boundingBox, { ScreenRect? focusRect }) {
    return CameraUpdate._({
      'type': 'newBounds',
      'params': {
        'boundingBox': boundingBox.toJson(),
        'focusRect': focusRect?.toJson()
      }
    });
  }

  /// Returns a camera update so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level in the custom focus rect.
  /// If [focusRect] is null then the current focus rect is used.
  /// The camera's new tilt and bearing will both be 0.0.
  ///
  /// Will be removed in future versions. Instead use [newTiltAzimuthGeometry]
  @deprecated
  static CameraUpdate newTiltAzimuthBounds(BoundingBox boundingBox, {
    double azimuth = 0,
    double tilt = 0,
    ScreenRect? focusRect
  }) {
    return newTiltAzimuthGeometry(
      Geometry.fromBoundingBox(boundingBox),
      azimuth: azimuth,
      tilt: tilt,
      focusRect: focusRect
    );
  }

  /// Returns a camera update so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level in the custom focus rect.
  /// If [focusRect] is null then the current focus rect is used.
  /// The camera's new tilt and bearing will both be 0.0.
  static CameraUpdate newTiltAzimuthGeometry(Geometry geometry, {
    double azimuth = 0,
    double tilt = 0,
    ScreenRect? focusRect
  }) {
    return CameraUpdate._({
      'type': 'newTiltAzimuthGeometry',
      'params': {
        'geometry': geometry.toJson(),
        'azimuth': azimuth,
        'tilt': tilt,
        'focusRect': focusRect?.toJson()
      }
    });
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static CameraUpdate zoomIn() {
    return CameraUpdate._({
      'type': 'zoomIn'
    });
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static CameraUpdate zoomOut() {
    return CameraUpdate._({
      'type': 'zoomOut'
    });
  }

  /// Returns a camera update that sets the camera zoom level.
  static CameraUpdate zoomTo(double zoom) {
    return CameraUpdate._({
      'type': 'zoomTo',
      'params': {
        'zoom': zoom
      }
    });
  }

  /// Returns a camera update that sets the camera bearing.
  static CameraUpdate azimuthTo(double azimuth) {
    return CameraUpdate._({
      'type': 'azimuthTo',
      'params': {
        'azimuth': azimuth
      }
    });
  }

  /// Returns a camera update that sets the camera bearing.
  static CameraUpdate tiltTo(double tilt) {
    return CameraUpdate._({
      'type': 'tiltTo',
      'params': {
        'tilt': tilt
      }
    });
  }

  final dynamic _json;

  dynamic toJson() => _json;
}
