part of yandex_mapkit;

/// A collection of [PlacemarkMapObject] to be displayed on [YandexMap]
///
/// Depending on distance from each other and current zoom level
/// can be grouped into a single or multiple [Cluster]
class ClusterizedPlacemarkCollection extends Equatable implements MapObject {
  ClusterizedPlacemarkCollection({
    required this.mapId,
    required List<PlacemarkMapObject> placemarks,
    required this.radius,
    required this.minZoom,
    this.zIndex = 0.0,
    this.onTap,
    this.onClusterAdded,
    this.onClusterTap,
    this.consumeTapEvents = false,
    this.isVisible = true
  }) : placemarks = List.unmodifiable(placemarks.groupFoldBy<MapObjectId, PlacemarkMapObject>(
      (element) => element.mapId,
      (previous, element) => element
    ).values);

  /// List of [PlacemarkMapObject] eligible for clusterization.
  ///
  /// All [placemarks] must be unique, i.e. each [MapObject.mapId] must be unique
  final List<PlacemarkMapObject> placemarks;

  /// z-order
  ///
  /// Affects:
  /// 1. Rendering order.
  /// 2. Dispatching of UI events(taps and drags are dispatched to objects with higher z-indexes first).
  final double zIndex;

  /// Minimal zoom level that displays clusters.
  ///
  /// All placemarks will be rendered separately at more detailed zoom levels.
  final int minZoom;

  /// Minimal distance in units between objects that remain separate.
  final double radius;

  /// Callback to call when any of this collection [placemarks] receives a tap
  final TapCallback<ClusterizedPlacemarkCollection>? onTap;

  /// Callback to be called when a cluster has been added to [YandexMap].
  ///
  /// You can return [Cluster] with changed [Cluster.appearance] to change how it is shown on the map.
  final ClusterCallback? onClusterAdded;

  /// Callback to be called when a previously created [Cluster] is tapped.
  final ClusterTapCallback? onClusterTap;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  /// True if the placemark consumes tap events.
  /// If not, the map will propagate tap events to other map objects at the point of tap.
  final bool consumeTapEvents;

  /// Creates a modified copy.
  ///
  /// Specified fields will get the specified value, all other fields will get
  /// the same value from the current object.
  ClusterizedPlacemarkCollection copyWith({
    List<PlacemarkMapObject>? placemarks,
    double? radius,
    int? minZoom,
    double? zIndex,
    TapCallback<ClusterizedPlacemarkCollection>? onTap,
    ClusterCallback? onClusterAdded,
    ClusterCallback? onClusterTap,
    bool? consumeTapEvents,
    bool? isVisible
  }) {
    return ClusterizedPlacemarkCollection(
      mapId: mapId,
      placemarks: placemarks ?? this.placemarks,
      radius: radius ?? this.radius,
      minZoom: minZoom ?? this.minZoom,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      onClusterAdded: onClusterAdded ?? this.onClusterAdded,
      onClusterTap: onClusterTap ?? this.onClusterTap,
      consumeTapEvents: consumeTapEvents ?? this.consumeTapEvents,
      isVisible: isVisible ?? this.isVisible
    );
  }

  Future<Cluster?> _clusterAdd(Cluster cluster) async {
    if (onClusterAdded != null) {
      return onClusterAdded!(this, cluster);
    }

    return null;
  }

  void _clusterTap(Cluster cluster) {
    if (onClusterTap != null) {
      onClusterTap!(this, cluster);
    }
  }

  @override
  final MapObjectId mapId;

  @override
  ClusterizedPlacemarkCollection clone() => copyWith();

  @override
  ClusterizedPlacemarkCollection dup(MapObjectId mapId) {
    return ClusterizedPlacemarkCollection(
      mapId: mapId,
      placemarks: placemarks,
      radius: radius,
      minZoom: minZoom,
      zIndex: zIndex,
      onTap: onTap,
      onClusterAdded: onClusterAdded,
      onClusterTap: onClusterTap,
      consumeTapEvents: consumeTapEvents,
      isVisible: isVisible
    );
  }

  @override
  void _tap(Point point) {
    if (onTap != null) {
      onTap!(this, point);
    }
  }

  /// Stub for [MapObject]
  /// [ClusterizedPlacemarkCollection] does not support drag
  @override
  void _dragStart() {
    throw UnsupportedError;
  }

  /// Stub for [MapObject]
  /// [ClusterizedPlacemarkCollection] does not support drag
  @override
  void _drag(Point point) {
    throw UnsupportedError;
  }

  /// Stub for [MapObject]
  /// [ClusterizedPlacemarkCollection] does not support drag
  @override
  void _dragEnd() {
    throw UnsupportedError;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': mapId.value,
      'radius': radius,
      'minZoom': minZoom,
      'placemarks': placemarks.map((PlacemarkMapObject p) => p.toJson()).toList(),
      'zIndex': zIndex,
      'consumeTapEvents': consumeTapEvents,
      'isVisible': isVisible
    };
  }

  @override
  Map<String, dynamic> _createJson() {
    return toJson()..addAll({
      'type': runtimeType.toString(),
      'placemarks': MapObjectUpdates.from(
        const <PlacemarkMapObject>{...[]},
        placemarks.toSet()
      ).toJson()
    });
  }

  @override
  Map<String, dynamic> _updateJson(MapObject previous) {
    assert(mapId == previous.mapId);

    return toJson()..addAll({
      'type': runtimeType.toString(),
      'placemarks': MapObjectUpdates.from(
        (previous as ClusterizedPlacemarkCollection).placemarks.toSet(),
        placemarks.toSet()
      ).toJson()
    });
  }

  @override
  Map<String, dynamic> _removeJson() {
    return {
      'id': mapId.value,
      'type': runtimeType.toString()
    };
  }

  @override
  List<Object> get props => <Object>[
    mapId,
    placemarks,
    zIndex,
    consumeTapEvents,
    isVisible,
  ];

  @override
  bool get stringify => true;
}
