part of yandex_mapkit;

class MapAnimation extends Equatable {
  const MapAnimation({
    this.smooth = true,
    this.duration = 2.0
  });

  final double duration;
  final bool smooth;

  @override
  List<Object> get props => <Object>[
    smooth,
    duration
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'smooth': smooth,
      'duration': duration
    };
  }
}
