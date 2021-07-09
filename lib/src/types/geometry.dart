part of yandex_mapkit;

class Geometry {

  final Point?       point;
  final BoundingBox? boundingBox;

  Geometry({
    this.point,
    this.boundingBox,
  });

  Geometry.fromPoint(Point point) :
    point = point, boundingBox = null;

  Geometry.fromBoundingBox(BoundingBox boundingBox) :
        point = null, boundingBox = boundingBox;

  factory Geometry.fromJson(Map<dynamic, dynamic> json) {

    Point?        point;
    BoundingBox?  boundingBox;

    if (json.containsKey('point')) {
      point = Point(
        latitude: json['point']['latitude'],
        longitude: json['point']['longitude'],
      );
    } else if (json.containsKey('boundingBox')) {
      boundingBox = BoundingBox(
        southWest: Point(
          latitude: json['southWest']['latitude'],
          longitude: json['southWest']['longitude'],
        ),
        northEast: Point(
          latitude: json['northEast']['latitude'],
          longitude: json['northEast']['longitude'],
        ),
      );
    }

    return Geometry(
      point: point,
      boundingBox: boundingBox,
    );
  }
}