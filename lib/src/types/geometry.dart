part of yandex_mapkit;

class GeometryException implements YandexMapkitException {
  final String message;

  GeometryException._(this.message);
}
class Geometry extends Equatable {
  const Geometry.fromPoint(Point point) : point = point, boundingBox = null;
  const Geometry.fromBoundingBox(BoundingBox boundingBox) : point = null, boundingBox = boundingBox;

  final Point? point;
  final BoundingBox? boundingBox;

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

    throw GeometryException._('Invalid data: point or boundingBox keys required');
  }
}
