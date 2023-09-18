part of yandex_mapkit;

/// Defines the anchor points for user location layer
class UserLocationAnchor extends Equatable {
  const UserLocationAnchor({required this.normal, required this.course});

  /// The anchor position when the app is not on a steady course; usually, the center of the screen.
  final Offset normal;

  /// An anchor position near the bottom line for steady course mode.
  final Offset course;

  @override
  List<Object> get props => <Object>[course, normal];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'normal': {
        'dx': normal.dx,
        'dy': normal.dy,
      },
      'course': {
        'dx': course.dx,
        'dy': course.dy,
      }
    };
  }
}
