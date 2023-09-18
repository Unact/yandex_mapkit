part of yandex_mapkit;

/// The animation that is used to switch between states.
class MapAnimation extends Equatable {
  const MapAnimation(
      {this.type = MapAnimationType.smooth, this.duration = 2.0});

  /// Animation duration, in seconds.
  final double duration;

  /// Smooth interpolation between start and finish states or movement with constant speed during animation time.
  final MapAnimationType type;

  @override
  List<Object> get props => <Object>[type, duration];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'type': type.index, 'duration': duration};
  }
}

/// Animation types
enum MapAnimationType { smooth, linear }
