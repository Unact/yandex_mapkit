part of yandex_mapkit;

class YandexMapController extends ChangeNotifier {
  YandexMapController._(this._channel, this._yandexMapState) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final MethodChannel _channel;
  final _YandexMapState _yandexMapState;

  /// Root object which contains all [MapObject] which were created by [YandexMapController]
  MapObjectCollection _mapObjectCollection = MapObjectCollection(
    mapId: MapObjectId('root_map_object_collection'),
    mapObjects: []
  );

  /// All [MapObject] which were created natively by [YandexMap]
  ///
  /// This mainly refers to objects that can't be created by normal means
  /// Cluster placemarks, user location objects, etc.
  final List<MapObject> _nonRootMapObjects = [];

  /// All [MapObject] in [YandexMap]
  ///
  /// This contains all objects that were created by any means
  List<MapObject> get _allMapObjects => _mapObjectCollection.mapObjects + _nonRootMapObjects;

  static Future<YandexMapController> init(int id, _YandexMapState yandexMapState) async {
    final methodChannel = MethodChannel('yandex_mapkit/yandex_map_$id');
    await methodChannel.invokeMethod('waitForInit');

    return YandexMapController._(methodChannel, yandexMapState);
  }

  /// Set Yandex logo position
  Future<void> logoAlignment({
    required MapAlignment alignment
  }) async {
    await _channel.invokeMethod('logoAlignment', alignment.toJson());
  }

  /// Toggles night mode
  Future<void> toggleNightMode({required bool enabled}) async {
    await _channel.invokeMethod('toggleNightMode', {'enabled': enabled});
  }

  /// Toggles rotation of map
  Future<void> toggleMapRotation({required bool enabled}) async {
    await _channel.invokeMethod('toggleMapRotation', {'enabled': enabled});
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
    bool autoZoomEnabled = false
  }) async {
    await _channel.invokeMethod(
      'toggleUserLayer',
      {
        'visible': visible,
        'headingEnabled': headingEnabled,
        'autoZoomEnabled': autoZoomEnabled,
      }
    );
  }

  /// Applies styling to the map
  Future<void> setMapStyle({required String style}) async {
    await _channel.invokeMethod('setMapStyle', {'style': style});
  }

  /// Moves camera to specified [point]
  Future<void> move({
    required CameraPosition cameraPosition,
    MapAnimation? animation
  }) async {
    await _channel.invokeMethod(
      'move',
      {
        'cameraPosition': cameraPosition.toJson(),
        'animation': animation?.toJson(),
      }
    );
  }

  /// Moves map to include area inside [southWestPoint] and [northEastPoint]
  Future<void> setBounds({
    required BoundingBox boundingBox,
    MapAnimation? animation
  }) async {
    await _channel.invokeMethod(
      'setBounds',
      {
        'boundingBox': boundingBox.toJson(),
        'animation': animation?.toJson(),
      }
    );
  }

  /// Allows to set map focus to a certain rectangle instead of the whole map
  /// For more info refer to [YMKMapWindow.focusRect](https://yandex.ru/dev/maps/archive/doc/mapkit/3.0/concepts/ios/mapkit/ref/YMKMapWindow.html#property_detail__property_focusRect)
  Future<void> setFocusRect({
    required ScreenRect screenRect
  }) async {
    await _channel.invokeMethod('setFocusRect', screenRect.toJson());
  }

  /// Clears focusRect set by `YandexMapController.setFocusRect`
  Future<void> clearFocusRect() async {
    await _channel.invokeMethod('clearFocusRect');
  }

  /// Changes map objects on the map
  /// This method allows manipulating(adding, updating, deleting) map objects on the map
  /// [updatedMapObjects] defines all map objects that should be present on the map
  /// After this call:
  /// 1. All currently present map objects not in [updatedMapObjects] will be removed from the map
  /// 2. All new map objects in [updatedMapObjects] that aren't present on the map will be added
  /// 3. All map objects present in [updatedMapObjects] and are on the map will be updated
  Future<void> updateMapObjects(List<MapObject> updatedMapObjects) async {
    final updatedMapObjectCollection = _mapObjectCollection.copyWith(mapObjects: updatedMapObjects);
    final mapObjectUpdates = MapObjectUpdates.from({_mapObjectCollection}, {updatedMapObjectCollection});

    await _channel.invokeMethod('updateMapObjects', mapObjectUpdates.toJson());
    _mapObjectCollection = updatedMapObjectCollection;
  }

  /// Increases current zoom by 1
  Future<void> zoomIn() async {
    await _channel.invokeMethod('zoomIn');
  }

  /// Decreases current zoom by 1
  Future<void> zoomOut() async {
    await _channel.invokeMethod('zoomOut');
  }

  Future<bool> isZoomGesturesEnabled() async {
    final bool value = await _channel.invokeMethod('isZoomGesturesEnabled');

    return value;
  }

  /// Toggles isZoomGesturesEnabled (enable/disable zoom gestures)
  Future<void> toggleZoomGestures({required bool enabled}) async {
    await _channel.invokeMethod('toggleZoomGestures', {'enabled': enabled});
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

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
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
      case 'onMapObjectTap':
        return _onMapObjectTap(call.arguments);
      case 'onMapSizeChanged':
        return _onMapSizeChanged(call.arguments);
      case 'onUserLocationAdded':
        return await _onUserLocationAdded(call.arguments);
      case 'onCameraPositionChanged':
        return _onCameraPositionChanged(call.arguments);
      default:
        throw YandexMapkitException();
    }
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

  void _onMapSizeChanged(dynamic arguments) {
    if (_yandexMapState.widget.onMapSizeChanged == null) {
      return;
    }

    _yandexMapState.widget.onMapSizeChanged!(MapSize._fromJson(arguments['mapSize']));
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
    final pin = Placemark(
      mapId: MapObjectId('user_location_pin'),
      point: Point._fromJson(arguments['pinPoint'])
    );
    final arrow = Placemark(
      mapId: MapObjectId('user_location_arrow'),
      point: Point._fromJson(arguments['arrowPoint'])
    );
    final accuracyCircle = Circle(
      mapId: MapObjectId('user_location_accuracy_circle'),
      center: Point._fromJson(arguments['circle']['center']),
      radius: arguments['circle']['radius']
    );
    final view = UserLocationView._(arrow: arrow, pin: pin, accuracyCircle: accuracyCircle);
    final newView = _yandexMapState.widget.onUserLocationAdded != null ?
      (await _yandexMapState.widget.onUserLocationAdded!(view)) :
      view;
    final newPin = newView?.pin.dup(pin.mapId) ?? pin;
    final newArrow = newView?.arrow.dup(arrow.mapId) ?? arrow;
    final newAccuracyCircle = newView?.accuracyCircle.dup(accuracyCircle.mapId) ?? accuracyCircle;

    _nonRootMapObjects.addAll([newPin, newArrow, newAccuracyCircle]);

    return {
      'pin': newPin.toJson(),
      'arrow': newArrow.toJson(),
      'accuracyCircle': newAccuracyCircle.toJson()
    };
  }

  void _onClustersRemoved(dynamic arguments) {
    final appearancePlacemarkIds = arguments['appearancePlacemarkIds'];

    for (var appearancePlacemarkId in appearancePlacemarkIds) {
      _nonRootMapObjects.remove(_findMapObject(_allMapObjects, appearancePlacemarkId));
    }
  }

  Future<Map<String, dynamic>> _onClusterAdded(dynamic arguments) async {
    final id = arguments['id'];
    final size = arguments['size'];
    final mapObject = _findMapObject(_allMapObjects, id) as ClusterizedPlacemarkCollection;
    final placemarks = arguments['placemarkIds']
      .map<Placemark>((el) => _findMapObject(mapObject.placemarks, el) as Placemark)
      .toList();
    final appearance = Placemark(
      mapId: MapObjectId(arguments['appearancePlacemarkId']),
      point: Point._fromJson(arguments['point'])
    );
    final cluster = Cluster._(size: size, appearance: appearance, placemarks: placemarks);
    final newAppearance = (await mapObject._clusterAdd(cluster))?.appearance ?? cluster.appearance;

    _nonRootMapObjects.add(newAppearance);

    return newAppearance.toJson();
  }

  void _onClusterTap(dynamic arguments) {
    final id = arguments['id'];
    final size = arguments['size'];
    final mapObject = _findMapObject(_allMapObjects, id) as ClusterizedPlacemarkCollection;
    final placemarks = arguments['placemarkIds']
      .map<Placemark>((el) => _findMapObject(mapObject.placemarks, el) as Placemark)
      .toList();
    final appearance = _findMapObject(_allMapObjects, arguments['appearancePlacemarkId']) as Placemark;
    final cluster = Cluster._(size: size, appearance: appearance, placemarks: placemarks);

    mapObject._clusterTap(cluster);
  }

  void _onMapObjectTap(dynamic arguments) {
    final id = arguments['id'];
    final point = Point._fromJson(arguments['point']);
    final mapObject = _findMapObject(_allMapObjects, id);

    mapObject!._tap(point);
  }

  MapObject? _findMapObject(List<MapObject> mapObjects, String id) {
    for (var mapObject in mapObjects) {
      var foundMapObject;

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

  Future<bool> isTiltGesturesEnabled() async {
    final bool value = await _channel.invokeMethod('isTiltGesturesEnabled');
    return value;
  }

  /// Toggles isTiltGesturesEnabled (enable/disable tilt gestures)
  Future<void> toggleTiltGestures({required bool enabled}) async {
    await _channel.invokeMethod('toggleTiltGestures', {'enabled': enabled});
  }
}
