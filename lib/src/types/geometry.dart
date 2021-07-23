part of yandex_mapkit;

class Geometry {

  final Point?       point;
  final BoundingBox? boundingBox;

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
      return Geometry.fromPoint(point);
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
      return Geometry.fromBoundingBox(boundingBox);
    }

    throw('Invalid data: point or boundingBox keys required');
  }

  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{};

    if (point != null) {
      json['point'] = {
        'latitude': point!.latitude,
        'longitude': point!.longitude,
      };
    } else {
      json['boundingBox'] = {
        'southWest': {
          'latitude': boundingBox!.southWest.latitude,
          'longitude': boundingBox!.southWest.longitude,
        },
        'northEast': {
          'latitude': boundingBox!.northEast.latitude,
          'longitude': boundingBox!.northEast.longitude,
        },
      };
    }

    return json;
  }
}
