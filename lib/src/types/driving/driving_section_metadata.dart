part of yandex_mapkit;

class DrivingSectionMetadata extends Equatable {
  final DrivingWeight weight;

  DrivingSectionMetadata._(this.weight);

  factory DrivingSectionMetadata._fromJson(Map<dynamic, dynamic> json) {
    return DrivingSectionMetadata._(DrivingWeight._fromJson(json['weight']));
  }

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

  factory DrivingWeight._fromJson(Map<dynamic, dynamic> json) {
    return DrivingWeight._(
      LocalizedValue._fromJson(json['time']),
      LocalizedValue._fromJson(json['timeWithTraffic']),
      LocalizedValue._fromJson(json['distance']),
    );
  }

  @override
  List<Object> get props => <Object>[
    time,
    timeWithTraffic,
    distance,
  ];

  @override
  bool get stringify => true;
}
