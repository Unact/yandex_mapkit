part of yandex_mapkit;

/// A rectangular box around the object.
class BoundingBox extends Equatable {
  const BoundingBox({
    required this.northEast,
    required this.southWest,
  });

  /// The coordinates of the northeast corner of the box.
  final Point northEast;

  /// The coordinates of the southwest corner of the box.
  final Point southWest;

  @override
  List<Object> get props => <Object>[
        northEast,
        southWest,
      ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'northEast': northEast.toJson(),
      'southWest': southWest.toJson(),
    };
  }

  factory BoundingBox._fromJson(Map<dynamic, dynamic> json) {
    return BoundingBox(
        northEast: Point._fromJson(json['northEast']),
        southWest: Point._fromJson(json['southWest']));
  }
}
