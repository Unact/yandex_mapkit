part of yandex_mapkit;

class Cluster {

  final int       hashValue;
  final int       size;
  final Point     geometry;
  final List<int> placemarks;

  Cluster({
    required this.hashValue,
    required this.size,
    required this.geometry,
    required this.placemarks,
  });

  factory Cluster.fromJson(Map<dynamic, dynamic> json) {

    return Cluster(
      hashValue:  json['hashValue'],
      size:       json['size'],
      geometry: Point(
        latitude:   json['appearance']['geometry']['latitude'],
        longitude:  json['appearance']['geometry']['longitude'],
      ),
      placemarks: json['placemarks'].cast<int>(),
    );
  }
}
