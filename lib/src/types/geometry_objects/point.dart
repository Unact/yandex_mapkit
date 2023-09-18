part of yandex_mapkit;

/// A point at the specified coordinates.
class Point extends Equatable {
  const Point({required this.latitude, required this.longitude});

  /// The point's latitude.
  final double latitude;

  /// The point's longitude
  final double longitude;

  @override
  List<Object> get props => <Object>[latitude, longitude];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Point._fromJson(Map<dynamic, dynamic> json) {
    return Point(latitude: json['latitude'], longitude: json['longitude']);
  }
}
