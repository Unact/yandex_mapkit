part of yandex_mapkit;

class YandexMapController extends ChangeNotifier {
  YandexMapController._(this._channel, this._yandexMapState) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const double kTilt = 0.0;
  static const double kAzimuth = 0.0;
  static const double kZoom = 15.0;
  static const Color kAccuracyCircleFillColor = Colors.blueGrey;
  static const bool kUserArrowOrientation = true;

  final MethodChannel _channel;
  final _YandexMapState _yandexMapState;

  final List<Placemark> placemarks = <Placemark>[];
  final List<Polyline> polylines = <Polyline>[];
  final List<Polygon> polygons = <Polygon>[];
  CameraPositionCallback _cameraPositionCallback;

  static YandexMapController init(int id, _YandexMapState yandexMapState) {
    final MethodChannel methodChannel = MethodChannel('yandex_mapkit/yandex_map_$id');

    return YandexMapController._(methodChannel, yandexMapState);
  }

  /// Toggles night mode for YMKMap/com.yandex.mapkit.map
  Future<void> toggleNightMode({@required bool enabled}) async {
    await _channel.invokeMethod<void>(
      'toggleNightMode',
      <String, dynamic>{
        'enabled': enabled
      }
    );
  }

  /// Toggles rotation of map for YMKMap/com.yandex.mapkit.map
  Future<void> toggleMapRotation({@required bool enabled}) async {
    await _channel.invokeMethod<void>(
      'toggleMapRotation',
      <String, dynamic>{
        'enabled': enabled
      }
    );
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
  Future<void> showUserLayer(
      {@required String iconName,
      @required String arrowName,
      bool userArrowOrientation = kUserArrowOrientation,
      Color accuracyCircleFillColor = kAccuracyCircleFillColor}) async {
    await _channel.invokeMethod<void>(
      'showUserLayer',
      <String, dynamic>{
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
    await _channel.invokeMethod<void>('hideUserLayer');
  }

  /// Applies styling to the map
  Future<void> setMapStyle({@required String style}) async {
    await _channel.invokeMethod<void>(
        'setMapStyle',
        <String, dynamic>{
          'style': style
        }
    );
  }

  Future<void> move({
    @required Point point,
    double zoom = kZoom,
    double azimuth = kAzimuth,
    double tilt = kTilt,
    MapAnimation animation
  }) async {
    await _channel.invokeMethod<void>(
      'move',
      <String, dynamic>{
        'latitude': point.latitude,
        'longitude': point.longitude,
        'zoom': zoom,
        'azimuth': azimuth,
        'tilt': tilt,
        'animate': animation != null,
        'smoothAnimation': animation?.smooth,
        'animationDuration': animation?.duration
      }
    );
  }

  Future<void> setBounds({
    @required Point southWestPoint,
    @required Point northEastPoint,
    MapAnimation animation
  }) async {
    await _channel.invokeMethod<void>(
      'setBounds',
      <String, dynamic>{
        'southWestLatitude': southWestPoint.latitude,
        'southWestLongitude': southWestPoint.longitude,
        'northEastLatitude': northEastPoint.latitude,
        'northEastLongitude': northEastPoint.longitude,
        'animate': animation != null,
        'smoothAnimation': animation?.smooth,
        'animationDuration': animation?.duration
      }
    );
  }

  /// Does nothing if passed `Placemark` is `null`
  Future<void> addPlacemark(Placemark placemark) async {
    if (placemark != null) {
      await _channel.invokeMethod<void>('addPlacemark', _placemarkParams(placemark));
      placemarks.add(placemark);
    }
  }

  Future<void> disableCameraTracking() async {
    _cameraPositionCallback = null;
    await _channel.invokeMethod<void>('disableCameraTracking');
  }

  Future<Point> enableCameraTracking(
    Placemark placemark,
    CameraPositionCallback callback
  ) async {
    _cameraPositionCallback = callback;

    final dynamic point = await _channel.invokeMethod<dynamic>(
      'enableCameraTracking',
      placemark != null ? _placemarkParams(placemark) : null
    );
    return Point(latitude: point['latitude'], longitude: point['longitude']);
  }

  // Does nothing if passed `Placemark` wasn't added before
  Future<void> removePlacemark(Placemark placemark) async {
    if (placemarks.remove(placemark)) {
      await _channel.invokeMethod<void>(
        'removePlacemark',
        <String, dynamic>{
          'hashCode': placemark.hashCode
        }
      );
    }
  }

  /// Does nothing if passed `Polyline` is `null`
  Future<void> addPolyline(Polyline polyline) async {
    if (polyline != null) {
      await _channel.invokeMethod<void>('addPolyline', _polylineParams(polyline));
      polylines.add(polyline);
    }
  }

  /// Does nothing if passed `Polyline` wasn't added before
  Future<void> removePolyline(Polyline polyline) async {
    if (polylines.remove(polyline)) {
      await _channel.invokeMethod<void>(
        'removePolyline',
        <String, dynamic>{
          'hashCode': polyline.hashCode
        }
      );
    }
  }

  // Does nothing if passed `Polygon` is `null`
  Future<void> addPolygon(Polygon polygon) async {
    if (polygon != null) {
      await _channel.invokeMethod<void>('addPolygon', _polygonParams(polygon));
      polygons.add(polygon);
    }
  }

  // Does nothing if passed `Polygon` wasn't added before
  Future<void> removePolygon(Polygon polygon) async {
    if (polygons.remove(polygon)) {
      await _channel.invokeMethod<void>(
          'removePolygon', <String, dynamic>{'hashCode': polygon.hashCode});
    }
  }

  Future<void> zoomIn() async {
    await _channel.invokeMethod<void>('zoomIn');
  }

  Future<void> zoomOut() async {
    await _channel.invokeMethod<void>('zoomOut');
  }

  Future<void> moveToUser() async {
    await _channel.invokeMethod<void>('moveToUser');
  }

  Future<Point> getTargetPoint() async {
    final dynamic point = await _channel.invokeMethod<dynamic>('getTargetPoint');
    return Point(latitude: point['latitude'], longitude: point['longitude']);
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
      case 'onCameraPositionChanged':
        _onCameraPositionChanged(call.arguments);
        break;
      default:
        throw MissingPluginException();
    }
  }

  void _onMapTap(dynamic arguments) {
    _yandexMapState.onMapTap(Point(latitude: arguments['latitude'], longitude: arguments['longitude']));
  }

  void _onMapLongTap(dynamic arguments) {
    _yandexMapState.onMapLongTap(Point(latitude: arguments['latitude'], longitude: arguments['longitude']));
  }

  void _onMapObjectTap(dynamic arguments) {
    final int hashCode = arguments['hashCode'];
    final Point point = Point(latitude: arguments['latitude'], longitude: arguments['longitude']);

    final Placemark placemark = placemarks.
      firstWhere((Placemark placemark) => placemark.hashCode == hashCode, orElse: () => null);

    if (placemark != null) {
      placemark.onTap(point);
    }
  }

  void _onCameraPositionChanged(dynamic arguments) {
    _cameraPositionCallback(arguments);
  }

  Map<String, dynamic> _placemarkParams(Placemark placemark) {
    return <String, dynamic>{
      'latitude': placemark.point.latitude,
      'longitude': placemark.point.longitude,
      'anchorX': placemark.iconAnchor.latitude,
      'anchorY': placemark.iconAnchor.longitude,
      'scale': placemark.scale,
      'zIndex' : placemark.zIndex,
      'opacity': placemark.opacity,
      'isDraggable': placemark.isDraggable,
      'iconName': placemark.iconName,
      'rawImageData': placemark.rawImageData,
      'hashCode': placemark.hashCode,
      'rotationType': placemark.rotationType,
      'direction': placemark.direction
    };
  }

  Map<String, dynamic> _polylineParams(Polyline polyline) {
    final List<Map<String, double>> coordinates = polyline.coordinates.map(
      (Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude}
    ).toList();
    return <String, dynamic>{
      'coordinates': coordinates,
      'strokeColor': polyline.strokeColor.value,
      'strokeWidth': polyline.strokeWidth,
      'outlineColor': polyline.outlineColor.value,
      'outlineWidth': polyline.outlineWidth,
      'isGeodesic': polyline.isGeodesic,
      'dashLength': polyline.dashLength,
      'dashOffset': polyline.dashOffset,
      'gapLength': polyline.gapLength,
      'hashCode': polyline.hashCode
    };
  }

  Map<String, dynamic> _polygonParams(Polygon polygon) {
    final List<Map<String, double>> coordinates = polygon.coordinates.map(
      (Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude}
    ).toList();
    return <String, dynamic>{
      'coordinates': coordinates,
      'strokeColor': polygon.strokeColor.value,
      'strokeWidth': polygon.strokeWidth,
      'fillColor': polygon.fillColor.value,
      'isGeodesic': polygon.isGeodesic,
      'hashCode': polygon.hashCode
    };
  }
}
