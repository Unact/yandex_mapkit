part of yandex_mapkit;

class YandexMapController extends ChangeNotifier {
  YandexMapController._(this._channel, this._yandexMapState) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final MethodChannel _channel;
  final _YandexMapState _yandexMapState;

  static Future<YandexMapController> _init(int id, _YandexMapState yandexMapState) async {
    final methodChannel = MethodChannel('yandex_mapkit/yandex_map_$id');
    await methodChannel.invokeMethod('waitForInit');

    return YandexMapController._(methodChannel, yandexMapState);
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  /// Toggles current user location layer
  ///
  /// Requires location permissions:
  ///
  /// iOS: `NSLocationWhenInUseUsageDescription`
  /// Android: `android.permission.ACCESS_FINE_LOCATION`
  ///
  /// Does nothing if these permissions were denied
  Future<void> toggleUserLayer({
    required bool visible,
    bool headingEnabled = true,
    bool autoZoomEnabled = false,
    UserLocationAnchor? anchor
  }) async {
    await _channel.invokeMethod(
      'toggleUserLayer',
      {
        'visible': visible,
        'headingEnabled': headingEnabled,
        'autoZoomEnabled': autoZoomEnabled,
        'anchor': anchor?.toJson()
      }
    );
  }

  /// Toggles layer with traffic information
  Future<void> toggleTrafficLayer({
    required bool visible
  }) async {
    await _channel.invokeMethod(
      'toggleTrafficLayer',
      {
        'visible': visible
      }
    );
  }

  /// Selects a geo object with the specified objectId in the specified layerId.
  /// If the object is not currently on the screen, it is selected anyway, but the user will not actually see that.
  /// You need to move the camera in addition to this call to be sure that the selected object is visible for the user.
  Future<void> selectGeoObject(String objectId, String layerId) async {
    await _channel.invokeMethod('selectGeoObject', {
      'objectId': objectId,
      'layerId': layerId
    });
  }

  /// Resets the currently selected geo object.
  Future<void> deselectGeoObject() async {
    await _channel.invokeMethod('deselectGeoObject');
  }

  /// Applies JSON style transformations to the map.
  /// Set to empty string to clear previous styling.
  ///
  /// Returns true if the style was successfully parsed, and false otherwise.
  /// If the returned value is false, the current map style remains unchanged.
  ///
  /// For styling details refer to https://yandex.com/dev/maps/mapkit/doc/dg/concepts/style.html
  Future<bool> setMapStyle(String style) async {
    return await _channel.invokeMethod('setMapStyle', {'style': style});
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the platform side.
  /// Returns true if camera position has been succesfully changes
  /// Returns false if camera position movement has been canceled
  /// (for example, as a result of a subsequent request for camera movement)
  Future<bool> moveCamera(CameraUpdate cameraUpdate, {
    MapAnimation? animation
  }) async {
    return await _channel.invokeMethod(
      'moveCamera',
      {
        'cameraUpdate': cameraUpdate.toJson(),
        'animation': animation?.toJson(),
      }
    );
  }

  /// Transforms the position from map coordinates to screen coordinates.
  ///
  /// [ScreenPoint] is relative to the top left of the map.
  /// Returns null if [Point] is behind camera.
  Future<ScreenPoint?> getScreenPoint(Point point) async {
    final dynamic result = await _channel.invokeMethod('getScreenPoint', point.toJson());

    if (result != null) {
      return ScreenPoint._fromJson(result);
    }

    return null;
  }

  /// Transforms the position from screen coordinates to map coordinates.
  ///
  /// [ScreenPoint] should be relative to the top left of the map.
  /// Returns null if the resulting [Point] is behind camera.
  Future<Point?> getPoint(ScreenPoint screenPoint) async {
    final dynamic result = await _channel.invokeMethod('getPoint', screenPoint.toJson());

    if (result != null) {
      return Point._fromJson(result);
    }

    return null;
  }

  // Returns min available zoom for visible map region
  Future<double> getMinZoom() async {
    final double minZoom = await _channel.invokeMethod('getMinZoom');

    return minZoom;
  }

  // Returns max available zoom for visible map region
  Future<double> getMaxZoom() async {
    final double maxZoom = await _channel.invokeMethod('getMaxZoom');

    return maxZoom;
  }

  /// Returns current user position point
  /// Before using this method user layer must be visible
  /// [YandexMapController.toggleUserLayer] must be called with `visible: true`
  ///
  /// [CameraPosition] is returned only if native YandexMap successfully calculates current position
  Future<CameraPosition?> getUserCameraPosition() async {
    final dynamic result = await _channel.invokeMethod('getUserCameraPosition');

    if (result != null) {
      return CameraPosition._fromJson(result['cameraPosition']);
    }

    return null;
  }

  /// Returns current camera position
  Future<CameraPosition> getCameraPosition() async {
    final dynamic result = await _channel.invokeMethod('getCameraPosition');

    return CameraPosition._fromJson(result['cameraPosition']);
  }

  /// Get bounds of visible map area
  Future<VisibleRegion> getVisibleRegion() async {
    final dynamic result = await _channel.invokeMethod('getVisibleRegion');

    return VisibleRegion._fromJson(result['visibleRegion']);
  }

  /// Gets the region corresponding to current focusRect or the visible region if focusRect hasn't been set.
  ///
  /// In contrast to [getVisibleRegion] this also takes into account focusRect.
  Future<VisibleRegion> getFocusRegion() async {
    final dynamic result = await _channel.invokeMethod('getFocusRegion');

    return VisibleRegion._fromJson(result['focusRegion']);
  }

  /// Changes current map options
  Future<void> _updateMapOptions(Map<String, dynamic> options) async {
    await _channel.invokeMethod('updateMapOptions', options);
  }

  /// Changes map objects on the map
  Future<void> _updateMapObjects(Map<String, dynamic> updates) async {
    await _channel.invokeMethod('updateMapObjects', updates);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTrafficChanged':
        return _onTrafficChanged(call.arguments);
      case 'onMapTap':
        return _onMapTap(call.arguments);
      case 'onClustersRemoved':
        return _onClustersRemoved(call.arguments);
      case 'onClusterAdded':
        return _onClusterAdded(call.arguments);
      case 'onClusterTap':
        return _onClusterTap(call.arguments);
      case 'onMapLongTap':
        return _onMapLongTap(call.arguments);
      case 'onObjectTap':
        return _onObjectTap(call.arguments);
      case 'onMapObjectTap':
        return _onMapObjectTap(call.arguments);
      case 'onMapObjectDragStart':
        return _onMapObjectDragStart(call.arguments);
      case 'onMapObjectDrag':
        return _onMapObjectDrag(call.arguments);
      case 'onMapObjectDragEnd':
        return _onMapObjectDragEnd(call.arguments);
      case 'onUserLocationAdded':
        return await _onUserLocationAdded(call.arguments);
      case 'onCameraPositionChanged':
        return _onCameraPositionChanged(call.arguments);
      default:
        throw MissingPluginException();
    }
  }

  void _onObjectTap(dynamic arguments) {
    if (_yandexMapState.widget.onObjectTap == null) {
      return;
    }

    _yandexMapState.widget.onObjectTap!(GeoObject._fromJson(arguments['geoObject']));
  }

  void _onMapTap(dynamic arguments) {
    if (_yandexMapState.widget.onMapTap == null) {
      return;
    }

    _yandexMapState.widget.onMapTap!(Point._fromJson(arguments['point']));
  }

  void _onMapLongTap(dynamic arguments) {
    if (_yandexMapState.widget.onMapLongTap == null) {
      return;
    }

    _yandexMapState.widget.onMapLongTap!(Point._fromJson(arguments['point']));
  }

  void _onCameraPositionChanged(dynamic arguments) {
    if (_yandexMapState.widget.onCameraPositionChanged == null) {
      return;
    }

    _yandexMapState.widget.onCameraPositionChanged!(
      CameraPosition._fromJson(arguments['cameraPosition']),
      CameraUpdateReason.values[arguments['reason']],
      arguments['finished']
    );
  }

  Future<Map<String, dynamic>?> _onUserLocationAdded(dynamic arguments) async {
    final pin = PlacemarkMapObject(
      mapId: const MapObjectId('user_location_pin'),
      point: Point._fromJson(arguments['pinPoint'])
    );
    final arrow = PlacemarkMapObject(
      mapId: const MapObjectId('user_location_arrow'),
      point: Point._fromJson(arguments['arrowPoint'])
    );
    final accuracyCircle = CircleMapObject(
      mapId: const MapObjectId('user_location_accuracy_circle'),
      circle: Circle._fromJson(arguments['circle'])
    );
    final view = UserLocationView._(arrow: arrow, pin: pin, accuracyCircle: accuracyCircle);
    final newView = _yandexMapState.widget.onUserLocationAdded != null ?
      (await _yandexMapState.widget.onUserLocationAdded!(view)) :
      view;
    final newPin = newView?.pin.dup(pin.mapId) ?? pin;
    final newArrow = newView?.arrow.dup(arrow.mapId) ?? arrow;
    final newAccuracyCircle = newView?.accuracyCircle.dup(accuracyCircle.mapId) ?? accuracyCircle;

    _yandexMapState._nonRootMapObjects.addAll([newPin, newArrow, newAccuracyCircle]);

    return {
      'pin': newPin.toJson(),
      'arrow': newArrow.toJson(),
      'accuracyCircle': newAccuracyCircle.toJson()
    };
  }

  void _onClustersRemoved(dynamic arguments) {
    final appearancePlacemarkIds = arguments['appearancePlacemarkIds'];

    for (var appearancePlacemarkId in appearancePlacemarkIds) {
      _yandexMapState._nonRootMapObjects.remove(_findMapObject(_yandexMapState._allMapObjects, appearancePlacemarkId));
    }
  }

  Future<Map<String, dynamic>> _onClusterAdded(dynamic arguments) async {
    final id = arguments['id'];
    final size = arguments['size'];
    final mapObject = _findMapObject(_yandexMapState._allMapObjects, id) as ClusterizedPlacemarkCollection;
    final placemarks = arguments['placemarkIds']
      .map<PlacemarkMapObject>((el) => _findMapObject(mapObject.placemarks, el) as PlacemarkMapObject)
      .toList();
    final appearance = PlacemarkMapObject(
      mapId: MapObjectId(arguments['appearancePlacemarkId']),
      point: Point._fromJson(arguments['point'])
    );
    final cluster = Cluster._(size: size, appearance: appearance, placemarks: placemarks);
    final newAppearance = (await mapObject._clusterAdd(cluster))?.appearance ?? cluster.appearance;

    _yandexMapState._nonRootMapObjects.add(newAppearance);

    return newAppearance.toJson();
  }

  void _onClusterTap(dynamic arguments) {
    final id = arguments['id'];
    final size = arguments['size'];
    final mapObject = _findMapObject(_yandexMapState._allMapObjects, id) as ClusterizedPlacemarkCollection;
    final placemarks = arguments['placemarkIds']
      .map<PlacemarkMapObject>((el) => _findMapObject(mapObject.placemarks, el) as PlacemarkMapObject)
      .toList();
    final appearance = _findMapObject(
      _yandexMapState._allMapObjects,
      arguments['appearancePlacemarkId']
    ) as PlacemarkMapObject;
    final cluster = Cluster._(size: size, appearance: appearance, placemarks: placemarks);

    mapObject._clusterTap(cluster);
  }

  void _onMapObjectTap(dynamic arguments) {
    final id = arguments['id'];
    final point = Point._fromJson(arguments['point']);
    final mapObject = _findMapObject(_yandexMapState._allMapObjects, id);

    mapObject!._tap(point);
  }

  void _onMapObjectDragStart(dynamic arguments) {
    final id = arguments['id'];
    final mapObject = _findMapObject(_yandexMapState._allMapObjects, id);

    mapObject!._dragStart();
  }

  void _onMapObjectDrag(dynamic arguments) {
    final id = arguments['id'];
    final point = Point._fromJson(arguments['point']);
    final mapObject = _findMapObject(_yandexMapState._allMapObjects, id);

    mapObject!._drag(point);
  }

  void _onMapObjectDragEnd(dynamic arguments) {
    final id = arguments['id'];
    final mapObject = _findMapObject(_yandexMapState._allMapObjects, id);

    mapObject!._dragEnd();
  }

  void _onTrafficChanged(dynamic arguments) {
    if (_yandexMapState.widget.onTrafficChanged == null) {
      return;
    }

    final trafficLevel = arguments['trafficLevel'] == null ? null : TrafficLevel._fromJson(arguments['trafficLevel']);
    _yandexMapState.widget.onTrafficChanged!(trafficLevel);
  }

  MapObject? _findMapObject(List<MapObject> mapObjects, String id) {
    for (var mapObject in mapObjects) {
      MapObject? foundMapObject;

      if (mapObject.mapId.value == id) {
        foundMapObject = mapObject;
      }

      if (foundMapObject == null && mapObject is MapObjectCollection) {
        foundMapObject = _findMapObject(mapObject.mapObjects, id);
      }

      if (foundMapObject == null && mapObject is ClusterizedPlacemarkCollection) {
        foundMapObject = _findMapObject(mapObject.placemarks, id);
      }

      if (foundMapObject != null) {
        return foundMapObject;
      }
    }

    return null;
  }
}
