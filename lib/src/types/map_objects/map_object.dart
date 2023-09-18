part of yandex_mapkit;

/// Uniquely identifies object an among all [MapObjectCollection.mapObjects] of a specific type.
class MapObjectId extends Equatable {
  const MapObjectId(this.value);

  final String value;

  @override
  List<Object> get props => <Object>[value];

  @override
  bool get stringify => true;
}

/// A common interface for maps types.
abstract class MapObject<T> {
  /// A unique identifier for this object in the scope of a single [YandexMap]
  MapObjectId get mapId;

  /// Always process tap
  void _tap(Point point);

  /// Always process drag start
  void _dragStart();

  /// Always process drag
  void _drag(Point point);

  /// Always process drag end
  void _dragEnd();

  /// Returns a duplicate of this object.
  T clone();

  /// Creates a new copy of [T] with the same attributes as the original except its id
  T dup(MapObjectId mapId);

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson();

  /// Returns all needed data to create this object
  Map<String, dynamic> _createJson();

  /// Returns all needed data to update this object
  Map<String, dynamic> _updateJson(MapObject previous);

  /// Returns all needed data to remove this object
  Map<String, dynamic> _removeJson();
}
