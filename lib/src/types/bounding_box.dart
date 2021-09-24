part of yandex_mapkit;

class BoundingBox extends Equatable {
  const BoundingBox({
    required this.northEast,
    required this.southWest,
  });

  final Point northEast;
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

  factory BoundingBox.fromJson(Map<dynamic, dynamic> json) {
    return BoundingBox(
      northEast: Point.fromJson(json['northEast']),
      southWest: Point.fromJson(json['southWest'])
    );
  }
}
