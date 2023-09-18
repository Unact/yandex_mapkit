part of yandex_mapkit;

/// A geometric representation of an object on map
class Geometry extends Equatable {
  const Geometry._(
      {this.boundingBox,
      this.circle,
      this.multiPolygon,
      this.point,
      this.polyline,
      this.polygon});

  /// A rectangular box around the object.
  final BoundingBox? boundingBox;

  /// A circle around the specified point.
  final Circle? circle;

  /// An area consisting of multiple external polygons.
  final MultiPolygon? multiPolygon;

  /// A point at the specified coordinates.
  final Point? point;

  /// A polygon with one or more polygons in it.
  final Polygon? polygon;

  /// A polyline between a number of points.
  final Polyline? polyline;

  factory Geometry.fromBoundingBox(BoundingBox boundingBox) =>
      Geometry._(boundingBox: boundingBox);

  factory Geometry.fromCircle(Circle circle) => Geometry._(circle: circle);

  factory Geometry.fromMultiPolygon(MultiPolygon multiPolygon) =>
      Geometry._(multiPolygon: multiPolygon);

  factory Geometry.fromPoint(Point point) => Geometry._(point: point);

  factory Geometry.fromPolygon(Polygon polygon) => Geometry._(polygon: polygon);

  factory Geometry.fromPolyline(Polyline polyline) =>
      Geometry._(polyline: polyline);

  @override
  List<Object?> get props => <Object?>[
        boundingBox,
        circle,
        multiPolygon,
        point,
        polygon,
        polyline,
      ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'boundingBox': boundingBox?.toJson(),
      'circle': circle?.toJson(),
      'multiPolygon': multiPolygon?.toJson(),
      'point': point?.toJson(),
      'polygon': polygon?.toJson(),
      'polyline': polyline?.toJson(),
    };
  }

  factory Geometry._fromJson(Map<dynamic, dynamic> json) {
    return Geometry._(
      boundingBox: json['boundingBox'] != null
          ? BoundingBox._fromJson(json['boundingBox'])
          : null,
      circle: json['circle'] != null ? Circle._fromJson(json['circle']) : null,
      multiPolygon: json['multiPolygon'] != null
          ? MultiPolygon._fromJson(json['multiPolygon'])
          : null,
      point: json['point'] != null ? Point._fromJson(json['point']) : null,
      polygon:
          json['polygon'] != null ? Polygon._fromJson(json['polygon']) : null,
      polyline: json['polyline'] != null
          ? Polyline._fromJson(json['polyline'])
          : null,
    );
  }
}
