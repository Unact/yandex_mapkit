part of yandex_mapkit;

class BoundingBox extends Equatable {

  final Point southWest;
  final Point northEast;

  BoundingBox({
    required this.southWest,
    required this.northEast,
  });

  @override
  List<Object> get props => <Object>[
    southWest,
    northEast,
  ];

  @override
  bool get stringify => true;
}
