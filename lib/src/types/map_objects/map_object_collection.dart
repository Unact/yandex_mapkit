part of yandex_mapkit;

/// A collection of [MapObject] to be displayed on [YandexMap]
/// All [mapObjects] must be unique, i.e. each [MapObject.mapId] must be unique
class MapObjectCollection extends Equatable implements MapObject {
  MapObjectCollection({
    required this.mapId,
    required List<MapObject> mapObjects,
    this.zIndex = 0.0,
    this.onTap,
    this.consumeTapEvents = false,
    this.isVisible = true
  }) : mapObjects = List.unmodifiable(mapObjects.groupFoldBy<MapObjectId, MapObject>(
      (element) => element.mapId,
      (previous, element) => element
    ).values);

  /// List of [MapObject] in this collection.
  ///
  /// All [mapObjects] must be unique, i.e. each [MapObject.mapId] must be unique
  final List<MapObject> mapObjects;

  /// z-order
  ///
  /// Affects:
  /// 1. Rendering order.
  /// 2. Dispatching of UI events(taps and drags are dispatched to objects with higher z-indexes first).
  final double zIndex;

  /// Callback to call when any of this collection [mapObjects] receives a tap
  final TapCallback<MapObjectCollection>? onTap;

  /// True if the placemark consumes tap events.
  /// If not, the map will propagate tap events to other map objects at the point of tap.
  final bool consumeTapEvents;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  MapObjectCollection copyWith({
    List<MapObject>? mapObjects,
    double? zIndex,
    TapCallback<MapObjectCollection>? onTap,
    bool? consumeTapEvents,
    bool? isVisible
  }) {
    return MapObjectCollection(
      mapId: mapId,
      mapObjects: mapObjects ?? this.mapObjects,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      consumeTapEvents: consumeTapEvents ?? this.consumeTapEvents,
      isVisible: isVisible ?? this.isVisible
    );
  }

  @override
  final MapObjectId mapId;

  @override
  MapObjectCollection clone() => copyWith();

  @override
  MapObjectCollection dup(MapObjectId mapId) {
    return MapObjectCollection(
      mapId: mapId,
      mapObjects: mapObjects,
      zIndex: zIndex,
      onTap: onTap,
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
  /// [MapObjectCollection] does not support drag
  @override
  void _dragStart() {
    throw UnsupportedError;
  }

  /// Stub for [MapObject]
  /// [MapObjectCollection] does not support drag
  @override
  void _drag(Point point) {
    throw UnsupportedError;
  }

  /// Stub for [MapObject]
  /// [MapObjectCollection] does not support drag
  @override
  void _dragEnd() {
    throw UnsupportedError;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': mapId.value,
      'mapObjects': mapObjects.map((MapObject p) => p.toJson()).toList(),
      'zIndex': zIndex,
      'consumeTapEvents': consumeTapEvents,
      'isVisible': isVisible
    };
  }

  @override
  Map<String, dynamic> _createJson() {
    return toJson()..addAll({
      'type': runtimeType.toString(),
      'mapObjects': MapObjectUpdates.from(
        const <MapObject>{...[]},
        mapObjects.toSet()
      ).toJson()
    });
  }

  @override
  Map<String, dynamic> _updateJson(MapObject previous) {
    assert(mapId == previous.mapId);

    return toJson()..addAll({
      'type': runtimeType.toString(),
      'mapObjects': MapObjectUpdates.from(
        (previous as MapObjectCollection).mapObjects.toSet(),
        mapObjects.toSet()
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
    mapObjects,
    zIndex,
    consumeTapEvents,
    isVisible
  ];

  @override
  bool get stringify => true;
}
