part of yandex_mapkit;

class DrivingSectionMetadata {
  DrivingSectionMetadata(this.weight);

  final DrivingWeight weight;
}

class DrivingWeight {
  DrivingWeight(this.time, this.timeWithTraffic, this.distance);

  final LocalizedValue time;
  final LocalizedValue timeWithTraffic;
  final LocalizedValue distance;
}
