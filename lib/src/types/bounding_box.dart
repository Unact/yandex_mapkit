part of yandex_mapkit;

class BoundingBox extends Equatable {
  final Point southWest;
  final Point northEast;

  BoundingBox({
    required this.southWest,
    required this.northEast,
  });

  Map<String, dynamic> toJson() {
    return {
      'southWest': {
        'latitude': southWest.latitude,
        'longitude': southWest.longitude,
      },
      'northEast': {
        'latitude': northEast.latitude,
        'longitude': northEast.longitude,
      }
    };
  }

  @override
  List<Object> get props => <Object>[
    southWest,
    northEast,
  ];

  @override
  bool get stringify => true;
}
