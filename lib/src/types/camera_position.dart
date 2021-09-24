part of yandex_mapkit;

class CameraPosition extends Equatable {
  const CameraPosition({
    required this.target,
    this.zoom = 15.0,
    this.tilt = 0.0,
    this.azimuth = 0.0,
  });

  final Point target;
  final double zoom;
  final double tilt;
  final double azimuth;

  @override
  List<Object> get props => <Object>[
    target,
    zoom,
    tilt,
    azimuth
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'target': target.toJson(),
      'zoom': zoom,
      'tilt': tilt,
      'azimuth': azimuth
    };
  }

  factory CameraPosition.fromJson(Map<dynamic, dynamic> json) {
    return CameraPosition(
      target: Point.fromJson(json['target']),
      zoom: json['zoom'],
      tilt: json['tilt'],
      azimuth: json['azimuth'],
    );
  }
}
