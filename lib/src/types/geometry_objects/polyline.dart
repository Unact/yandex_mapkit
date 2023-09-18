part of yandex_mapkit;

/// A polyline between a number of points.
/// A polyline is drawn between consecutive points.
class Polyline extends Equatable {
  const Polyline({required this.points});

  /// The list of points to connect.
  final List<Point> points;

  @override
  List<Object> get props => <Object>[points];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {'points': points.map((Point p) => p.toJson()).toList()};
  }

  factory Polyline._fromJson(Map<dynamic, dynamic> json) {
    return Polyline(
        points:
            json['points'].map<Point>((el) => Point._fromJson(el)).toList());
  }
}
