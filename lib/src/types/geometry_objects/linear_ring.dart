part of yandex_mapkit;

/// A sequence of four or more vertices, with all points along the
/// linearly-interpolated curves (line segments) between each pair of
/// consecutive vertices. A ring must have either 0, 4 or more points.
/// The first and last points of the ring must be in the same position.
/// The ring must not intersect with itself.
class LinearRing extends Equatable {
  const LinearRing({required this.points});

  /// The list of points to connect.
  final List<Point> points;

  @override
  List<Object> get props => <Object>[points];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {'points': points.map((Point p) => p.toJson()).toList()};
  }

  factory LinearRing._fromJson(Map<dynamic, dynamic> json) {
    return LinearRing(
        points:
            json['points'].map<Point>((el) => Point._fromJson(el)).toList());
  }
}
