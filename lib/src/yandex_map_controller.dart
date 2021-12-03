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

  /// Set Yandex logo position
  Future<void> logoAlignment({
    required MapAlignment alignment
  }) async {
    await _channel.invokeMethod('logoAlignment', alignment.toJson());
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

  /// Increases current zoom by 1
  Future<void> zoomIn() async {
    await _channel.invokeMethod('zoomIn');
  }

  /// Decreases current zoom by 1
  Future<void> zoomOut() async {
    await _channel.invokeMethod('zoomOut');
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
      case 'onMapObjectDragStart':
        return _onMapObjectDragStart(call.arguments);
      case 'onMapObjectDrag':
        return _onMapObjectDrag(call.arguments);
      case 'onMapObjectDragEnd':
        return _onMapObjectDragEnd(call.arguments);
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
      .map<Placemark>((el) => _findMapObject(mapObject.placemarks, el) as Placemark)
      .toList();
    final appearance = Placemark(
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
      .map<Placemark>((el) => _findMapObject(mapObject.placemarks, el) as Placemark)
      .toList();
    final appearance = _findMapObject(_yandexMapState._allMapObjects, arguments['appearancePlacemarkId']) as Placemark;
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
}
