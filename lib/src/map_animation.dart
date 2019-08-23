class MapAnimation {
  const MapAnimation({this.smooth = true, this.duration = kAnimationDuration});

  final double duration;
  final bool smooth;

  static const double kAnimationDuration = 2.0;
}
