part of yandex_mapkit;

/// A geometric representation of an object on map
/// Only Point and BoundingBox geometries are supported
class Geometry extends Equatable {
  const Geometry.fromPoint(this.point) : boundingBox = null;
  const Geometry.fromBoundingBox(this.boundingBox) : point = null;

  /// A point at the specified coordinates.
  final Point? point;

  /// A rectangular box around the object.
  final BoundingBox? boundingBox;

  const Geometry._({
    this.point,
    this.boundingBox
  });

  @override
  List<Object?> get props => <Object?>[
    point,
    boundingBox,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'point': point?.toJson(),
      'boundingBox': boundingBox?.toJson()
    };
  }

  factory Geometry._fromJson(Map<dynamic, dynamic> json) {
    if (json['point'] != null) {
      return Geometry.fromPoint(Point._fromJson(json['point']));
    }

    if (json['boundingBox'] != null) {
      return Geometry.fromBoundingBox(BoundingBox._fromJson(json['boundingBox']));
    }

    return Geometry._();
  }
}
