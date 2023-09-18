part of yandex_mapkit;

/// A number placemarks grouped into single placemark created for [ClusterizedPlacemarkCollection]
/// [Cluster]
class Cluster extends Equatable {
  const Cluster._(
      {required this.size, required this.appearance, required this.placemarks});

  /// Placemarks from [ClusterizedPlacemarkCollection] in this cluster
  final List<PlacemarkMapObject> placemarks;

  /// Number of placemarks in this cluster
  final int size;

  /// Placemark which indicates how to visually show cluster on [YandexMap]
  final PlacemarkMapObject appearance;

  /// Returns a copy of [Cluster] with new appearance
  Cluster copyWith({PlacemarkMapObject? appearance}) {
    return Cluster._(
        size: size,
        appearance: appearance ?? this.appearance,
        placemarks: placemarks);
  }

  @override
  List<Object> get props => <Object>[size, appearance, placemarks];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'appearance': appearance.toJson(),
      'placemarks': placemarks.map((e) => e.toJson())
    };
  }
}
