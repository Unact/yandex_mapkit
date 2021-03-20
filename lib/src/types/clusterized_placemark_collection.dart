part of yandex_mapkit;

class ClusterizedPlacemarkCollection {
  ClusterizedPlacemarkCollection({
    @required this.placemarks,
    this.clusterStyle = const PlacemarkStyle(),
    this.clusterRadius = 60,
    this.minZoom = 15,
    this.onClusterTap,
  });

  final List<PlacemarkCollection> placemarks;
  final PlacemarkStyle clusterStyle;
  final double clusterRadius;
  final int minZoom;
  final ArgumentCallback<List<dynamic>> onClusterTap;
}
