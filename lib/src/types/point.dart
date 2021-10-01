part of yandex_mapkit;

class Point extends Equatable {
  const Point({
    required this.latitude,
    required this.longitude
  });

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => <Object>[
    latitude,
    longitude
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Point._fromJson(Map<dynamic, dynamic> json) {
    return Point(
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}
