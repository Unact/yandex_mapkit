part of yandex_mapkit;

class YandexMapController extends ChangeNotifier {
  YandexMapController._(this._channel, this._yandexMapState) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final MethodChannel _channel;
  final _YandexMapState _yandexMapState;

  /// Has the native view been rendered
  bool _viewRendered = false;

  final List<Placemark> placemarks = <Placemark>[];
  final List<Polyline> polylines = <Polyline>[];
  final List<Polygon> polygons = <Polygon>[];
  final List<Circle> circles = <Circle>[];

  CameraPositionCallback? _cameraPositionCallback;

  static YandexMapController init(int id, _YandexMapState yandexMapState) {
    final methodChannel = MethodChannel('yandex_mapkit/yandex_map_$id');

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
  Future<Point> enableCameraTracking({
    required CameraPositionCallback onCameraPositionChange,
    PlacemarkStyle? style,
  }) async {
    _cameraPositionCallback = onCameraPositionChange;
    final dynamic result = await _channel.invokeMethod(
      'enableCameraTracking',
      {
        'style': style?.toJson()
      }
    );

    return Point.fromJson(result['point']);
  }

  /// Does nothing if passed `Placemark` is `null`
  Future<void> addPlacemark(Placemark placemark) async {
    await _channel.invokeMethod('addPlacemark', placemark.toJson());
    placemarks.add(placemark);
  }

  /// Does nothing if passed `Placemark` wasn't added before
  Future<void> removePlacemark(Placemark placemark) async {
    if (placemarks.remove(placemark)) {
      await _channel.invokeMethod('removePlacemark', placemark.toJson());
    }
  }

  Future<void> addPolyline(Polyline polyline) async {
    await _channel.invokeMethod('addPolyline', polyline.toJson());
    polylines.add(polyline);
  }

  /// Does nothing if passed `Polyline` wasn't added before
  Future<void> removePolyline(Polyline polyline) async {
    if (polylines.remove(polyline)) {
      await _channel.invokeMethod('removePolyline', polyline.toJson());
    }
  }

  Future<void> addPolygon(Polygon polygon) async {
    await _channel.invokeMethod('addPolygon', polygon.toJson());
    polygons.add(polygon);
  }

  /// Does nothing if passed `Polygon` wasn't added before
  Future<void> removePolygon(Polygon polygon) async {
    if (polygons.remove(polygon)) {
      await _channel.invokeMethod('removePolygon', polygon.toJson());
    }
  }

  Future<void> addCircle(Circle circle) async {
    await _channel.invokeMethod('addCircle', circle.toJson());
    circles.add(circle);
  }

  /// Does nothing if passed `Circle` wasn't added before
  Future<void> removeCircle(Circle circle) async {
    if (circles.remove(circle)) {
      await _channel.invokeMethod('removeCircle', circle.toJson());
    }
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
      return Point.fromJson(result['point']);
    }

    return null;
  }

  /// Returns current camera position point
  Future<Point> getTargetPoint() async {
    final dynamic result = await _channel.invokeMethod('getTargetPoint');

    return Point.fromJson(result['point']);
  }

  /// Get bounds of visible map area
  Future<VisibleRegion> getVisibleRegion() async {
    final dynamic result = await _channel.invokeMethod('getVisibleRegion');

    return VisibleRegion.fromJson(result['visibleRegion']);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onMapTap':
        _onMapTap(call.arguments);
        break;
      case 'onMapLongTap':
        _onMapLongTap(call.arguments);
        break;
      case 'onMapObjectTap':
        _onMapObjectTap(call.arguments);
        break;
      case 'onMapSizeChanged':
        _onMapSizeChanged(call.arguments);
        break;
      case 'onCameraPositionChanged':
        _onCameraPositionChanged(call.arguments);
        break;
      default:
        throw YandexMapkitException();
    }
  }

  void _onMapTap(dynamic arguments) {
    _yandexMapState.onMapTap(Point.fromJson(arguments['point']));
  }

  void _onMapLongTap(dynamic arguments) {
    _yandexMapState.onMapLongTap(Point.fromJson(arguments['point']));
  }

  void _onMapObjectTap(dynamic arguments) {
    final point = Point.fromJson(arguments['point']);
    final placemark = placemarks.firstWhere((Placemark placemark) => placemark.id == arguments['id']);

    if (placemark.onTap != null) {
      placemark.onTap!(placemark, point);
    }
  }

  void _onMapSizeChanged(dynamic arguments) {
    if (!_viewRendered) {
      _viewRendered = true;
      _yandexMapState.onMapRendered();
    }

    _yandexMapState.onMapSizeChanged(MapSize.fromJson(arguments['mapSize']));
  }

  void _onCameraPositionChanged(dynamic arguments) {
    _cameraPositionCallback!(
      CameraPosition.fromJson(arguments['cameraPosition']),
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
