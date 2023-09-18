part of yandex_mapkit;

/// A circle around the specified point.
class Circle extends Equatable {
  const Circle({required this.center, required this.radius});

  /// The list of points to connect.
  final Point center;

  /// The radius of the circle in meters.
  final double radius;

  @override
  List<Object> get props => <Object>[center, radius];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {'center': center.toJson(), 'radius': radius};
  }

  factory Circle._fromJson(Map<dynamic, dynamic> json) {
    return Circle(
        center: Point._fromJson(json['center']), radius: json['radius']);
  }
}
