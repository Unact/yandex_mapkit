part of yandex_mapkit;

/// A collection of [MapObject] to be displayed on [YandexMap]
/// All [mapObjects] must be unique, i.e. each [MapObject.mapId] must be unique
class MapObjectCollection extends Equatable implements MapObject {
  MapObjectCollection({
    required this.mapId,
    required List<MapObject> mapObjects,
    this.zIndex = 0.0,
    this.onTap,
    this.isVisible = true
  }) : _mapObjects = mapObjects.groupFoldBy<MapObjectId, MapObject>(
      (element) => element.mapId,
      (previous, element) => element
    ).values.toList();

  final List<MapObject> _mapObjects;
  List<MapObject> get mapObjects => List.unmodifiable(_mapObjects);

  final double zIndex;
  final TapCallback<MapObjectCollection>? onTap;

  /// Manages visibility of the object on the map.
  final bool isVisible;

  MapObjectCollection copyWith({
    List<MapObject>? mapObjects,
    double? zIndex,
    TapCallback<MapObjectCollection>? onTap,
    bool? isVisible
  }) {
    return MapObjectCollection(
      mapId: mapId,
      mapObjects: mapObjects ?? this.mapObjects,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
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
      isVisible: isVisible
    );
  }

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
      'zIndex': zIndex,
      'isVisible': isVisible
    };
  }

  @override
  Map<String, dynamic> _createJson() {
    return toJson()..addAll({
      'type': runtimeType.toString(),
      'mapObjects': MapObjectUpdates.from(
        <MapObject>{...[]},
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
    zIndex
  ];

  @override
  bool get stringify => true;
}
