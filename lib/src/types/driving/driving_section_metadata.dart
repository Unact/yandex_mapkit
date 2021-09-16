part of yandex_mapkit;

class DrivingSectionMetadata extends Equatable {
  final DrivingWeight weight;

  DrivingSectionMetadata._(this.weight);

  @override
  List<Object> get props => <Object>[
    weight,
  ];

  @override
  bool get stringify => true;
}

class DrivingWeight extends Equatable {
  final LocalizedValue time;
  final LocalizedValue timeWithTraffic;
  final LocalizedValue distance;

  DrivingWeight._(this.time, this.timeWithTraffic, this.distance);

  @override
  List<Object> get props => <Object>[
    time,
    timeWithTraffic,
    distance,
  ];

  @override
  bool get stringify => true;
}
