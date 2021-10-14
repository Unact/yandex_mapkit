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

  /// Has the native view been rendered
  bool _viewRendered = false;

  final List<Placemark> placemarks = <Placemark>[];
  final List<Polyline> polylines = <Polyline>[];
  final List<Polygon> polygons = <Polygon>[];
  CameraPositionCallback _cameraPositionCallback;
  ClusterizedPlacemarkCollection _clusterizedPlacemarkCollection;

  static YandexMapController init(int id, _YandexMapState yandexMapState) {
    final MethodChannel methodChannel = MethodChannel('yandex_mapkit/yandex_map_$id');

    return YandexMapController._(methodChannel, yandexMapState);
  }

  /// Set Yandex logo position
  Future<void> logoAlignment({
    @required HorizontalAlignment horizontal,
    @required VerticalAlignment vertical,
  }) async {
    await _channel.invokeMethod<void>('logoAlignment', <String, int>{
      'x': horizontal.index,
      'y': vertical.index,
    });
  }

  /// Toggles night mode
  Future<void> toggleNightMode({@required bool enabled}) async {
    await _channel.invokeMethod<void>(
      'toggleNightMode',
      <String, dynamic>{'enabled': enabled},
    );
  }

  /// Toggles rotation of map
  Future<void> toggleMapRotation({@required bool enabled}) async {
    await _channel.invokeMethod<void>(
      'toggleMapRotation',
      <String, dynamic>{'enabled': enabled},
    );
  }

  /// Toggles tilting of map
  Future<void> toggleMapTilting({@required bool enabled}) async {
    await _channel.invokeMethod<void>(
      'toggleMapTilting',
      <String, dynamic>{'enabled': enabled},
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
      },
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
      <String, dynamic>{'style': style},
    );
  }

  /// Moves camera to specified [point]
  Future<void> move({
    @required Point point,
    double zoom = kZoom,
    double azimuth = kAzimuth,
    double tilt = kTilt,
    MapAnimation animation,
  }) async {
    await _channel.invokeMethod<void>(
      'move',
      <String, dynamic>{
        'point': <String, dynamic>{
          'latitude': point.latitude,
          'longitude': point.longitude,
        },
        'animation': <String, dynamic>{
          'animate': animation != null,
          'smoothAnimation': animation?.smooth,
          'animationDuration': animation?.duration
        },
        'zoom': zoom,
        'azimuth': azimuth,
        'tilt': tilt,
      },
    );
  }

  /// Moves map to include area inside [southWestPoint] and [northEastPoint]
  Future<void> setBounds({
    @required Point southWestPoint,
    @required Point northEastPoint,
    MapAnimation animation,
  }) async {
    await _channel.invokeMethod<void>(
      'setBounds',
      <String, dynamic>{
        'southWestPoint': <String, dynamic>{
          'latitude': southWestPoint.latitude,
          'longitude': southWestPoint.longitude,
        },
        'northEastPoint': <String, dynamic>{
          'latitude': northEastPoint.latitude,
          'longitude': northEastPoint.longitude,
        },
        'animation': <String, dynamic>{
          'animate': animation != null,
          'smoothAnimation': animation?.smooth,
          'animationDuration': animation?.duration
        }
      },
    );
  }

  /// Does nothing if passed `Placemark` is `null`
  Future<void> addPlacemark(Placemark placemark) async {
    if (placemark != null) {
      await _channel.invokeMethod<void>(
        'addPlacemark',
        _placemarkParams(placemark),
      );
      placemarks.add(placemark);
    }
  }

  /// Disables listening for map camera updates
  Future<void> disableCameraTracking() async {
    _cameraPositionCallback = null;
    await _channel.invokeMethod<void>('disableCameraTracking');
  }

  /// Enables listening for map camera updates
  Future<Point> enableCameraTracking(
    PlacemarkStyle placemarkStyle,
    CameraPositionCallback callback,
  ) async {
    _cameraPositionCallback = callback;

    final dynamic point = await _channel.invokeMethod<dynamic>(
      'enableCameraTracking',
      placemarkStyle != null ? _placemarkStyleParams(placemarkStyle) : null,
    );
    return Point(latitude: point['latitude'], longitude: point['longitude']);
  }

  /// Does nothing if passed `Placemark` wasn't added before
  Future<void> removePlacemark(Placemark placemark) async {
    if (placemarks.remove(placemark)) {
      await _channel.invokeMethod<void>(
        'removePlacemark',
        <String, dynamic>{'hashCode': placemark.hashCode},
      );
    }
  }

  /// Does nothing if passed `Polyline` is `null`
  Future<void> addPolyline(Polyline polyline) async {
    if (polyline != null) {
      await _channel.invokeMethod<void>(
        'addPolyline',
        _polylineParams(polyline),
      );
      polylines.add(polyline);
    }
  }

  /// Does nothing if passed `Polyline` wasn't added before
  Future<void> removePolyline(Polyline polyline) async {
    if (polylines.remove(polyline)) {
      await _channel.invokeMethod<void>(
        'removePolyline',
        <String, dynamic>{'hashCode': polyline.hashCode},
      );
    }
  }

  /// Does nothing if passed `Polygon` is `null`
  Future<void> addPolygon(Polygon polygon) async {
    if (polygon != null) {
      await _channel.invokeMethod<void>('addPolygon', _polygonParams(polygon));
      polygons.add(polygon);
    }
  }

  /// Does nothing if passed `Polygon` wasn't added before
  Future<void> removePolygon(Polygon polygon) async {
    if (polygons.remove(polygon)) {
      await _channel.invokeMethod<void>(
        'removePolygon',
        <String, dynamic>{'hashCode': polygon.hashCode},
      );
    }
  }

  /// Increases current zoom by 1
  Future<void> zoomIn() async {
    await _channel.invokeMethod<void>('zoomIn');
  }

  /// Decreases current zoom by 1
  Future<void> zoomOut() async {
    await _channel.invokeMethod<void>('zoomOut');
  }

  /// Moves camera to user position
  Future<void> moveToUser() async {
    await _channel.invokeMethod<void>('moveToUser');
  }

  /// Returns current camera position point
  Future<Point> getTargetPoint() async {
    final dynamic point = await _channel.invokeMethod<dynamic>('getTargetPoint');
    return Point(latitude: point['latitude'], longitude: point['longitude']);
  }

  /// Get bounds of visible map area
  Future<Map<String, Point>> getVisibleRegion() async {
    final dynamic region = await _channel.invokeMethod<dynamic>('getVisibleRegion');
    return Map<String, Point>.of(<String, Point>{
      'bottomLeftPoint': Point(
        latitude: region['bottomLeftPoint']['latitude'],
        longitude: region['bottomLeftPoint']['longitude'],
      ),
      'bottomRightPoint': Point(
        latitude: region['bottomRightPoint']['latitude'],
        longitude: region['bottomRightPoint']['longitude'],
      ),
      'topLeftPoint': Point(
        latitude: region['topLeftPoint']['latitude'],
        longitude: region['topLeftPoint']['longitude'],
      ),
      'topRightPoint': Point(
        latitude: region['topRightPoint']['latitude'],
        longitude: region['topRightPoint']['longitude'],
      )
    });
  }

  Future<void> addClusterizedPlacemarkCollection(
    ClusterizedPlacemarkCollection collection,
  ) async {
    if (collection != null) {
      final args = _clusterizedPlacemarkCollectionParams(collection);
      await _channel.invokeMethod<void>(
        'addClusterizedPlacemarkCollection',
        args,
      );
      _clusterizedPlacemarkCollection = collection;
    }
  }

  Future<void> removeClusterizedPlacemarkCollection() async {
    await _channel.invokeMethod<void>('removeClusterizedPlacemarkCollection');
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
      case 'onClusterTap':
        _onClusterTap(call.arguments);
        break;
      case 'onClusterizedCollectionPlacemarkTap':
        _onClusterizedCollectionPlacemarkTap(call.arguments);
        break;
      default:
        throw MissingPluginException();
    }
  }

  void _onMapTap(dynamic arguments) {
    _yandexMapState.onMapTap(Point(
      latitude: arguments['latitude'],
      longitude: arguments['longitude'],
    ));
  }

  void _onMapLongTap(dynamic arguments) {
    _yandexMapState.onMapLongTap(Point(
      latitude: arguments['latitude'],
      longitude: arguments['longitude'],
    ));
  }

  void _onMapObjectTap(dynamic arguments) {
    final int hashCode = arguments['hashCode'];
    final Point point = Point(
      latitude: arguments['latitude'],
      longitude: arguments['longitude'],
    );

    final Placemark placemark = placemarks.firstWhere(
      (Placemark placemark) => placemark.hashCode == hashCode,
      orElse: () => null,
    );

    if (placemark != null && placemark.onTap != null) {
      placemark.onTap(point);
    }
  }

  void _onMapSizeChanged(dynamic arguments) {
    if (!_viewRendered) {
      _viewRendered = true;
      _yandexMapState.onMapRendered();
    }

    _yandexMapState.onMapSizeChanged(MapSize(
      width: arguments['width'],
      height: arguments['height'],
    ));
  }

  void _onCameraPositionChanged(dynamic arguments) {
    _cameraPositionCallback(arguments);
  }

  void _onClusterTap(dynamic arguments) {
    final List<dynamic> placemarkIds = arguments['placemarks'];
    if (_clusterizedPlacemarkCollection.onClusterTap != null) {
      _clusterizedPlacemarkCollection.onClusterTap(placemarkIds);
    }
  }

  void _onClusterizedCollectionPlacemarkTap(dynamic arguments) {
    final dynamic id = arguments['id'];

    PlacemarkCollectionItem tappedItem;
    for (var collection in _clusterizedPlacemarkCollection.placemarks) {
      final foundItems = collection.items.where((e) => e.id == id);
      if (foundItems.isNotEmpty) {
        tappedItem = foundItems.first;
        break;
      }
    }
    if (tappedItem?.onTap != null) {
      tappedItem.onTap(id);
    }
  }

  Map<String, dynamic> _placemarkParams(Placemark placemark) {
    return <String, dynamic>{
      'hashCode': placemark.hashCode,
      'point': <String, dynamic>{
        'latitude': placemark.point.latitude,
        'longitude': placemark.point.longitude,
      },
    }..addAll(_placemarkStyleParams(placemark.style));
  }

  Map<String, dynamic> _placemarkStyleParams(PlacemarkStyle style) {
    return <String, dynamic>{
      'style': _placemarkStyleInternalParams(style),
    };
  }

  Map<String, dynamic> _placemarkStyleInternalParams(PlacemarkStyle style) {
    return <String, dynamic>{
      'anchorX': style.iconAnchor.latitude,
      'anchorY': style.iconAnchor.longitude,
      'scale': style.scale,
      'zIndex': style.zIndex,
      'opacity': style.opacity,
      'isDraggable': style.isDraggable,
      'iconName': style.iconName,
      'rawImageData': style.rawImageData,
      'rotationType': style.rotationType.index,
      'direction': style.direction,
    };
  }

  Map<String, dynamic> _clusterizedPlacemarkCollectionParams(ClusterizedPlacemarkCollection collection) {
    return <String, dynamic>{
      'placemarks': collection.placemarks.map((x) => _placemarkCollectionParams(x)).toList(),
      'clusterStyle': _placemarkStyleInternalParams(collection.clusterStyle),
      'clusterRadius': collection.clusterRadius,
      'minZoom': collection.minZoom,
    };
  }

  Map<String, dynamic> _placemarkCollectionParams(PlacemarkCollection collection) {
    return <String, dynamic>{
      'items': collection.items.map((x) => _placemarkCollectionItemParams(x)).toList(),
    }..addAll(_placemarkStyleParams(collection.style));
  }

  Map<String, dynamic> _placemarkCollectionItemParams(PlacemarkCollectionItem item) {
    return <String, dynamic>{
      'point': <String, dynamic>{
        'latitude': item.point.latitude,
        'longitude': item.point.longitude,
      },
      'id': item.id,
    };
  }

  Map<String, dynamic> _polylineParams(Polyline polyline) {
    final List<Map<String, double>> coordinates = polyline.coordinates
        .map((Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude})
        .toList();

    return <String, dynamic>{'hashCode': polyline.hashCode, 'coordinates': coordinates}
      ..addAll(_polylineStyleParams(polyline.style));
  }

  Map<String, dynamic> _polylineStyleParams(PolylineStyle style) {
    return <String, dynamic>{
      'style': <String, dynamic>{
        'strokeColor': style.strokeColor.value,
        'strokeWidth': style.strokeWidth,
        'outlineColor': style.outlineColor.value,
        'outlineWidth': style.outlineWidth,
        'isGeodesic': style.isGeodesic,
        'dashLength': style.dashLength,
        'dashOffset': style.dashOffset,
        'gapLength': style.gapLength,
      }
    };
  }

  Map<String, dynamic> _polygonParams(Polygon polygon) {
    final List<Map<String, double>> coordinates = polygon.coordinates
        .map((Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude})
        .toList();

    return <String, dynamic>{
      'hashCode': polygon.hashCode,
      'coordinates': coordinates,
    }..addAll(_polygonStyleParams(polygon.style));
  }

  Map<String, dynamic> _polygonStyleParams(PolygonStyle style) {
    return <String, dynamic>{
      'style': <String, dynamic>{
        'strokeColor': style.strokeColor.value,
        'strokeWidth': style.strokeWidth,
        'fillColor': style.fillColor.value,
        'isGeodesic': style.isGeodesic,
      }
    };
  }
}
