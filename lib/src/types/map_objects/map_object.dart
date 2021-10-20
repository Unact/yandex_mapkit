part of yandex_mapkit;

/// Uniquely identifies object an among all [MapObjectCollection.mapObjects] of a specific type.
class MapObjectId<T> extends Equatable {
  const MapObjectId(this.value);

  final String value;

  @override
  List<Object> get props => <Object>[
    value
  ];

  @override
  bool get stringify => true;
}

/// A common interface for maps types.
abstract class MapObject<T> {
  /// A identifier for this object.
  MapObjectId<T> get mapId;

  /// Always process tap
  void _tap(Point point);

  /// Returns a duplicate of this object.
  T clone();

  /// Converts this object to something serializable in JSON.
  Map<String, dynamic> toJson();

  /// Returns all needed data to create this object
  Map<String, dynamic> _createJson();

  /// Returns all needed data to update this object
  Map<String, dynamic> _updateJson(MapObject previous);

  /// Returns all needed data to remove this object
  Map<String, dynamic> _removeJson();
}
