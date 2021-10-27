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

  CameraPositionCallback? _cameraPositionCallback;

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

  /// Shows an icon at current user location
  ///
  /// Requires location permissions:
  ///
  /// `NSLocationWhenInUseUsageDescription`
  ///
  /// `android.permission.ACCESS_FINE_LOCATION`
  ///
  /// Does nothing if these permissions where denied
  Future<void> showUserLayer({
    required String iconName,
    required String arrowName,
    bool userArrowOrientation = true,
    Color accuracyCircleFillColor = Colors.blueGrey
  }) async {
    await _channel.invokeMethod(
      'showUserLayer',
      {
        'iconName': iconName,
        'arrowName': arrowName,
        'userArrowOrientation': userArrowOrientation,
        'accuracyCircleFillColor': accuracyCircleFillColor.value
      }
    );
  }

  /// Hides an icon at current user location
  ///
  /// Requires location permissions:
  ///
  /// `NSLocationWhenInUseUsageDescription`
  ///
  /// `android.permission.ACCESS_FINE_LOCATION`
  ///
  /// Does nothing if these permissions where denied
  Future<void> hideUserLayer() async {
    await _channel.invokeMethod('hideUserLayer');
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

  /// Disables listening for map camera updates
  Future<void> disableCameraTracking() async {
    _cameraPositionCallback = null;
    await _channel.invokeMethod('disableCameraTracking');
  }

  /// Enables listening for map camera updates
  Future<void> enableCameraTracking({
    required CameraPositionCallback onCameraPositionChange,
  }) async {
    _cameraPositionCallback = onCameraPositionChange;
    await _channel.invokeMethod('enableCameraTracking');
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

  /// Returns current camera position point
  Future<double> getZoom() async {
    final double zoom = await _channel.invokeMethod('getZoom');

    return zoom;
  }

  /// Returns current user position point
  /// Before using this method [YandexMapController.showUserLayer] must be called
  /// [Point] is returned only if native YandexMap successfully calculates current position
  Future<Point?> getUserTargetPoint() async {
    final dynamic result = await _channel.invokeMethod('getUserTargetPoint');

    if (result['point'] != null) {
      return Point._fromJson(result['point']);
    }

    return null;
  }

  /// Returns current camera position point
  Future<Point> getTargetPoint() async {
    final dynamic result = await _channel.invokeMethod('getTargetPoint');

    return Point._fromJson(result['point']);
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
      case 'onCameraPositionChanged':
        return _onCameraPositionChanged(call.arguments);
      default:
        throw YandexMapkitException();
    }
  }

  void _onMapTap(dynamic arguments) {
    _yandexMapState.onMapTap(Point._fromJson(arguments['point']));
  }

  void _onClustersRemoved(dynamic arguments) {
    final appearancePlacemarkIds = arguments['appearancePlacemarkIds'];

    for (var appearancePlacemarkId in appearancePlacemarkIds) {
      _nonRootMapObjects.remove(_findMapObject(_allMapObjects, appearancePlacemarkId));
    }
  }

  Map<String, dynamic> _onClusterAdded(dynamic arguments) {
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
    final newAppearance = mapObject._clusterAdd(cluster)?.appearance ?? cluster.appearance;

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

  void _onMapLongTap(dynamic arguments) {
    _yandexMapState.onMapLongTap(Point._fromJson(arguments['point']));
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

  void _onMapSizeChanged(dynamic arguments) {
    _yandexMapState.onMapSizeChanged(MapSize._fromJson(arguments['mapSize']));
  }

  void _onCameraPositionChanged(dynamic arguments) {
    _cameraPositionCallback!(
      CameraPosition._fromJson(arguments['cameraPosition']),
      arguments['finished']
    );
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
