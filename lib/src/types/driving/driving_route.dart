part of yandex_mapkit;

class DrivingRoute extends Equatable {
  final List<Point> geometry;
  final DrivingSectionMetadata metadata;

  const DrivingRoute._(this.geometry, this.metadata);

  @override
  List<Object> get props => <Object>[
    geometry,
    metadata,
  ];

  @override
  bool get stringify => true;
}
