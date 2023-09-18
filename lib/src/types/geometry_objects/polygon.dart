part of yandex_mapkit;

/// A polygon with one or more polygons in it.
/// The exterior and interior areas are specified using LinearRing.
class Polygon extends Equatable {
  const Polygon({required this.outerRing, required this.innerRings});

  /// The ring specifying the area.
  final LinearRing outerRing;

  /// The list of rings in the specified area.
  final List<LinearRing> innerRings;

  @override
  List<Object> get props => <Object>[outerRing, innerRings];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'outerRing': outerRing.toJson(),
      'innerRings': innerRings.map((LinearRing lr) => lr.toJson()).toList()
    };
  }

  factory Polygon._fromJson(Map<dynamic, dynamic> json) {
    return Polygon(
        outerRing: LinearRing._fromJson(json['outerRing']),
        innerRings: json['innerRings']
            .map<LinearRing>((el) => LinearRing._fromJson(el))
            .toList());
  }
}
