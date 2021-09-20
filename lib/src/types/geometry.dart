part of yandex_mapkit;

class GeometryException implements YandexMapkitException {
  final String message;

  GeometryException(this.message);
}
class Geometry extends Equatable {
  final Point? point;
  final BoundingBox? boundingBox;

  Geometry.fromPoint(Point point) : point = point, boundingBox = null;
  Geometry.fromBoundingBox(BoundingBox boundingBox) : point = null, boundingBox = boundingBox;

  factory Geometry.fromJson(Map<dynamic, dynamic> json) {
    Point? point;
    BoundingBox? boundingBox;

    if (json.containsKey('point')) {
      point = Point.fromJson(json['point']);

      return Geometry.fromPoint(point);
    } else if (json.containsKey('boundingBox')) {
      boundingBox = BoundingBox(
        southWest: Point.fromJson(json['southWest']),
        northEast: Point.fromJson(json['northEast']),
      );

      return Geometry.fromBoundingBox(boundingBox);
    }

    throw GeometryException('Invalid data: point or boundingBox keys required');
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    if (point != null) {
      json['point'] = point!.toJson();
    } else {
      json['boundingBox'] = boundingBox!.toJson();
    }

    return json;
  }

  @override
  List<Object?> get props => <Object?>[
    point,
    boundingBox,
  ];

  @override
  bool get stringify => true;
}
