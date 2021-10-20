part of yandex_mapkit;

class MapObjectCollectionId extends MapObjectId<MapObjectCollection> {
  /// Creates an immutable identifier for a [MapObjectCollection].
  const MapObjectCollectionId(String value) : super(value);
}

/// A collection of [MapObject] to be displayed on [YandexMap]
/// All [mapObjects] must be unique, i.e. each [MapObject.mapId] must be unique
class MapObjectCollection extends Equatable implements MapObject {
  MapObjectCollection({
    required this.mapObjectCollectionId,
    required List<MapObject> mapObjects,
    this.zIndex = 0.0,
    this.onTap
  }) : _mapObjects = mapObjects.groupFoldBy<MapObjectId, MapObject>(
      (element) => element.mapId,
      (previous, element) => element
    ).values.toList();

  final List<MapObject> _mapObjects;
  List<MapObject> get mapObjects => List.unmodifiable(_mapObjects);

  final double zIndex;
  final TapCallback<MapObjectCollection>? onTap;

  final MapObjectCollectionId mapObjectCollectionId;

  MapObjectCollection copyWith({
    List<MapObject>? mapObjects,
    double? zIndex,
    TapCallback<MapObjectCollection>? onTap,
  }) {
    return MapObjectCollection(
      mapObjectCollectionId: mapObjectCollectionId,
      mapObjects: mapObjects ?? this.mapObjects,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap
    );
  }

  @override
  MapObjectCollectionId get mapId => mapObjectCollectionId;

  @override
  MapObjectCollection clone() => copyWith();

  @override
  void _tap(Point point) {
    if (onTap != null) {
      onTap!(this, point);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': mapId.value,
      'mapObjects': _mapObjects.map((MapObject p) => p.toJson()).toList(),
      'zIndex': zIndex
    };
  }

  @override
  Map<String, dynamic> _createJson() {
    return toJson()..addAll({
      'type': runtimeType.toString(),
      'mapObjects': MapObjectUpdates.from(
        <MapObjectCollection>{...[]},
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
      'type': runtimeType.toString(),
      'mapObjects': MapObjectUpdates.from(
        mapObjects.toSet(),
        <MapObjectCollection>{...[]},
      ).toJson()
    };
  }

  @override
  List<Object> get props => <Object>[
    mapObjectCollectionId,
    mapObjects,
    zIndex
  ];

  @override
  bool get stringify => true;
}
