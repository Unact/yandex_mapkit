import 'package:equatable/equatable.dart';

class MapAnimation extends Equatable {
  const MapAnimation({
    this.smooth = true, 
    this.duration = kAnimationDuration
  });

  final double duration;
  final bool smooth;

  static const double kAnimationDuration = 2.0;

  @override
  List<Object> get props => <Object>[
    smooth,
    duration
  ];

  @override
  bool get stringify => true;
}
