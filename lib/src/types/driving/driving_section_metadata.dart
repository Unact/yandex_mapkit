part of yandex_mapkit;

class DrivingSectionMetadata extends Equatable {
  DrivingSectionMetadata._(this.weight);

  final DrivingWeight weight;

  @override
  List<Object> get props => <Object>[
    weight,
  ];

  @override
  bool get stringify => true;
}

class DrivingWeight extends Equatable {
  DrivingWeight._(this.time, this.timeWithTraffic, this.distance);

  final LocalizedValue time;
  final LocalizedValue timeWithTraffic;
  final LocalizedValue distance;

  @override
  List<Object> get props => <Object>[
    time,
    timeWithTraffic,
    distance,
  ];

  @override
  bool get stringify => true;
}
