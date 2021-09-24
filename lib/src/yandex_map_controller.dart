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

  final List<ObjectsCollection> collections = <ObjectsCollection>[];

  final List<Placemark> placemarks  = <Placemark>[];
  final List<Polyline>  polylines   = <Polyline>[];
  final List<Polygon>   polygons    = <Polygon>[];
  final List<Circle>    circles     = <Circle>[];

  CameraPositionCallback?     _cameraPositionCallback;
  ArgumentCallback<Cluster>?  _onClusterAddedCallback;
  ArgumentCallback<Cluster>?  _onClusterTapCallback;

  static YandexMapController init(int id, _YandexMapState yandexMapState) {
    final methodChannel = MethodChannel('yandex_mapkit/yandex_map_$id');

    return YandexMapController._(methodChannel, yandexMapState);
  }

  /// Set Yandex logo position
  Future<void> logoAlignment({
    required HorizontalAlignment horizontal,
    required VerticalAlignment vertical
  }) async {
    await _channel.invokeMethod<void>('logoAlignment', <String, int>{'x': horizontal.index, 'y': vertical.index,});
  }

  /// Toggles night mode
  Future<void> toggleNightMode({required bool enabled}) async {
    await _channel.invokeMethod<void>('toggleNightMode', <String, dynamic>{'enabled': enabled});
  }

  /// Toggles rotation of map
  Future<void> toggleMapRotation({required bool enabled}) async {
    await _channel.invokeMethod<void>('toggleMapRotation', <String, dynamic>{'enabled': enabled});
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
    bool userArrowOrientation = kUserArrowOrientation,
    Color accuracyCircleFillColor = kAccuracyCircleFillColor
  }) async {
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
  Future<void> setMapStyle({required String style}) async {
    await _channel.invokeMethod<void>('setMapStyle', <String, dynamic>{'style': style});
  }

  /// Moves camera to specified [point]
  Future<void> move({
    required Point point,
    double zoom = kZoom,
    double azimuth = kAzimuth,
    double tilt = kTilt,
    MapAnimation? animation
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
      }
    );
  }

  /// Moves map to include area inside [southWestPoint] and [northEastPoint]
  Future<void> setBounds({
    required BoundingBox boundingBox,
    MapAnimation? animation
  }) async {
    await _channel.invokeMethod<void>(
      'setBounds',
      <String, dynamic>{
        'boundingBox': boundingBox.toJson(),
        'animation': <String, dynamic>{
          'animate': animation != null,
          'smoothAnimation': animation?.smooth,
          'animationDuration': animation?.duration
        }
      }
    );
  }

  /// Allows to set map focus to a certain rectangle instead of the whole map
  /// For more info refer to [YMKMapWindow.focusRect](https://yandex.ru/dev/maps/archive/doc/mapkit/3.0/concepts/ios/mapkit/ref/YMKMapWindow.html#property_detail__property_focusRect)
  Future<void> setFocusRect({
    required ScreenPoint bottomRight,
    required ScreenPoint topLeft
  }) async {
    await _channel.invokeMethod<void>(
      'setFocusRect',
      <String, dynamic>{
        'bottomRightScreenPoint': <String, dynamic>{
          'x': bottomRight.x,
          'y': bottomRight.y,
        },
        'topLeftScreenPoint': <String, dynamic>{
          'x': topLeft.x,
          'y': topLeft.y,
        }
      }
    );
  }

  /// Clears focusRect set by `YandexMapController.setFocusRect`
  Future<void> clearFocusRect() async {
    await _channel.invokeMethod<void>('clearFocusRect');
  }

  /// Adds a map objects collection for grouping map objects.
  ///
  /// Depending on isClusterized argument adds collections of different types:
  /// - isClusterized == false: YMKMapObjectCollection (can contain any map objects)
  /// - isClusterized == true: YMKClusterizedPlacemarkCollection (can contain only placemarks, used for placemarks clusterization)
  ///
  /// If parentId == null, collection will be created in root (mapObjects) collection.
  /// If not null parentId passed, will create a nested collection.
  /// YMKClusterizedPlacemarkCollection can't contain nested collections,
  /// attempts to create a collection inside it will lead to nothing.
  Future<void> addCollection(ObjectsCollection collection) async {

    var found = getCollectionById(collection.id);

    // Do not add if already exists
    if (found != null) {
      return;
    }

    var arguments = collection.toJson();

    await _channel.invokeMethod<void>('addCollection', arguments);

    collections.add(collection);
  }

  ObjectsCollection? getCollectionById(int collectionId) {

    var found = collections.where((coll) => coll.id == collectionId);

    if (found.isNotEmpty) {
      return found.first;
    }

    return null;
  }

  /// Does nothing if passed `Placemark` is `null`
  Future<void> addPlacemark(Placemark placemark) async {

    var arguments = placemark.toJson();

    await _channel.invokeMethod<void>('addPlacemark', arguments);

    placemarks.add(placemark);
  }

  /// Does nothing if passed `Placemark` is `null`
  Future<List<Placemark>> addPlacemarks({required List<Point> points, required PlacemarkIcon icon, int? collectionId}) async {

    var arguments = <String,dynamic>{};

    if (collectionId != null) {
      arguments['collectionId'] = collectionId;
    }

    arguments['points'] = points.map((p) => p.toJson()).toList();
    arguments['icon']   = icon.toJson();

    var placemarks  = <Placemark>[];
    var hashCodes   = [];

    for (var p in points) {
      var placemark = Placemark(point: p, icon: icon, collectionId: collectionId);
      hashCodes.add(placemark.hashCode);
      placemarks.add(placemark);
    }

    arguments['ids'] = hashCodes;

    await _channel.invokeMethod<void>('addPlacemarks', arguments);

    this.placemarks.addAll(placemarks);

    return placemarks;
  }

  /// Must be called to present clusterized placemarks after they are all added
  /// and every time the placemarks collection is updated.
  /// Callback applies a Cluster object - use it for cluster's icon updates
  Future<void> clusterPlacemarks({required int collectionId, required double clusterRadius, required int minZoom, required Function(Cluster) addedCallback, Function(Cluster)? tapCallback}) async {

    _onClusterAddedCallback = addedCallback;
    _onClusterTapCallback   = tapCallback;

    var arguments = <String,dynamic>{
      'collectionId':   collectionId,
      'clusterRadius':  clusterRadius,
      'minZoom':        minZoom,
    };

    await _channel.invokeMethod<void>('clusterPlacemarks', arguments);
  }

  /// Is called by mapkit when new cluster added - needed to set cluster icon
  void _onClusterAdded(dynamic arguments) {

    var cluster = Cluster.fromJson(arguments);

    // Call callback if not null to set cluster's icon inside
    if (_onClusterAddedCallback != null) {
      _onClusterAddedCallback!(cluster);
    }
  }

  /// Is called by mapkit when cluster tapped
  void _onClusterTap(dynamic arguments) {

    var cluster = Cluster.fromJson(arguments);

    // Call callback if not null
    if (_onClusterTapCallback != null) {
      _onClusterTapCallback!(cluster);
    }
  }

  /// Does nothing if passed `Placemark` is `null`
  Future<void> setClusterIcon({required int hashValue, required PlacemarkIcon icon}) async {

    var arguments = {};

    arguments['hashValue'] = hashValue;
    arguments['icon'] = icon.toJson();

    await _channel.invokeMethod<void>('setClusterIcon', arguments);
  }

  /// Disables listening for map camera updates
  Future<void> disableCameraTracking() async {
    _cameraPositionCallback = null;
    await _channel.invokeMethod<void>('disableCameraTracking');
  }

  /// Enables listening for map camera updates
  Future<Point> enableCameraTracking({
    required CameraPositionCallback onCameraPositionChange,
    Placemark? placemarkTemplate,
  }) async {
    _cameraPositionCallback = onCameraPositionChange;

    final dynamic point = await _channel.invokeMethod<dynamic>(
      'enableCameraTracking',
      placemarkTemplate != null
        ? {'placemarkTemplate': placemarkTemplate.toJson()}
        : null
    );
    return Point(latitude: point['latitude'], longitude: point['longitude']);
  }

  /// Does nothing if passed `Placemark` wasn't added before
  Future<void> removePlacemark(Placemark placemark) async {
    if (placemarks.remove(placemark)) {
      await _channel.invokeMethod<void>('removePlacemark', <String, dynamic>{'id': placemark.hashCode});
    }
  }

  /// Clears all map objects inside the collection including nested collections.
  /// If collectionId == null then clears root (mapObjects) collection
  /// Nested collections of target collection to be removed too.
  Future<void> clear({int? collectionId}) async {

    var arguments = {};

    if (collectionId != null) {
      arguments['collectionId'] = collectionId;
    }

    await _channel.invokeMethod<void>('clear', arguments);

    if (collectionId == null) { // Root collection (mapObjects)

      placemarks.clear();
      polylines.clear();
      polygons.clear();
      circles.clear();

      collections.clear();

    } else { // Nested collection (only placemarks)

      var collection = getCollectionById(collectionId);

      if (collection == null) {
        return;
      }

      if (collection.isClusterized) {

        // As clusterized collections can not be nested just remove all placemarks with parent = collectionId
        placemarks.removeWhere((p) => p.collectionId == collectionId);

      } else {

        var nestedCollectionsIds = <int>[];
        nestedCollectionsIds.add(collectionId);
        nestedCollectionsIds = _getNestedCollectionsIds(nestedCollectionsIds);

        // Remove all placemarks which parents are in the nestedCollectionsIds list
        placemarks.removeWhere((p) => nestedCollectionsIds.contains(p.collectionId));

        // Remove all nested collections except current one
        collections.removeWhere((c) => nestedCollectionsIds.contains(c.id) && c.id != collectionId);

        /*
        TODO: For now polylines, polygons and circles can be added only into the root collection (mapObjects),
         so there is no need to clear corresponding arrays, but should be implemented if addPolyline, addPolygon or addCircle
         will become to accept collectionId argument.
        */
      }
    }
  }

  List<int> _getNestedCollectionsIds(List<int> list) {

    var ids = list;

    for (var c in collections) {

      var id        = c.id;
      var parentId  = c.parentId;

      if (parentId == null) {
        continue;
      }

      if (ids.contains(parentId) && !ids.contains(id)) {
        ids.add(id);
        _getNestedCollectionsIds(ids);
      }
    }

    return ids;
  }

  Future<void> addPolyline(Polyline polyline) async {
    await _channel.invokeMethod<void>('addPolyline', _polylineParams(polyline));
    polylines.add(polyline);
  }

  /// Does nothing if passed `Polyline` wasn't added before
  Future<void> removePolyline(Polyline polyline) async {
    if (polylines.remove(polyline)) {
      await _channel.invokeMethod<void>('removePolyline', <String, dynamic>{'hashCode': polyline.hashCode});
    }
  }

  Future<void> addPolygon(Polygon polygon) async {
    await _channel.invokeMethod<void>('addPolygon', _polygonParams(polygon));
    polygons.add(polygon);
  }

  /// Does nothing if passed `Polygon` wasn't added before
  Future<void> removePolygon(Polygon polygon) async {
    if (polygons.remove(polygon)) {
      await _channel.invokeMethod<void>('removePolygon', <String, dynamic>{'hashCode': polygon.hashCode});
    }
  }

  Future<void> addCircle(Circle circle) async {
    await _channel.invokeMethod<void>('addCircle', _circleParams(circle));
    circles.add(circle);
  }

  /// Does nothing if passed `Circle` wasn't added before
  Future<void> removeCircle(Circle circle) async {
    if (circles.remove(circle)) {
      await _channel.invokeMethod<void>('removeCircle', <String, dynamic>{'hashCode': circle.hashCode});
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

  Future<bool> isZoomGesturesEnabled() async {
    final bool value = await _channel.invokeMethod<dynamic>('isZoomGesturesEnabled');
    return value;
  }

  /// Toggles isZoomGesturesEnabled (enable/disable zoom gestures)
  Future<void> toggleZoomGestures({required bool enabled}) async {
    await _channel.invokeMethod<void>('toggleZoomGestures', <String, dynamic>{'enabled': enabled});
  }

  // Returns min available zoom for visible map region
  Future<double> getMinZoom() async {
    final double minZoom = await _channel.invokeMethod<dynamic>('getMinZoom');
    return minZoom;
  }

  // Returns max available zoom for visible map region
  Future<double> getMaxZoom() async {
    final double maxZoom = await _channel.invokeMethod<dynamic>('getMaxZoom');
    return maxZoom;
  }

  /// Returns current camera position point
  Future<double> getZoom() async {
    final double zoom = await _channel.invokeMethod<dynamic>('getZoom');
    return zoom;
  }

  /// Returns current user position point only if user layer is visible
  Future<Point?> getUserTargetPoint() async {
    final dynamic point = await _channel.invokeMethod<dynamic>('getUserTargetPoint');

    if (point != null) {
      return Point(latitude: point['latitude'], longitude: point['longitude']);
    }

    return null;
  }

  /// Returns current camera position point
  Future<Point> getTargetPoint() async {
    final dynamic point = await _channel.invokeMethod<dynamic>('getTargetPoint');
    return Point(latitude: point['latitude'], longitude: point['longitude']);
  }

  /// Get bounds of visible map area
  Future<Map<String, Point>> getVisibleRegion() async {
    final dynamic region =
        await _channel.invokeMethod<dynamic>('getVisibleRegion');
    return Map<String, Point>.of(<String, Point>{
      'bottomLeftPoint': Point(
          latitude: region['bottomLeftPoint']['latitude'],
          longitude: region['bottomLeftPoint']['longitude']),
      'bottomRightPoint': Point(
          latitude: region['bottomRightPoint']['latitude'],
          longitude: region['bottomRightPoint']['longitude']),
      'topLeftPoint': Point(
          latitude: region['topLeftPoint']['latitude'],
          longitude: region['topLeftPoint']['longitude']),
      'topRightPoint': Point(
          latitude: region['topRightPoint']['latitude'],
          longitude: region['topRightPoint']['longitude'])
    });
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
      case 'onClusterAdded':
        _onClusterAdded(call.arguments);
        break;
      case 'onClusterTap':
        _onClusterTap(call.arguments);
        break;
      default:
        throw YandexMapkitException();
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
    final point = Point(latitude: arguments['latitude'], longitude: arguments['longitude']);
    final placemark = placemarks.firstWhere((Placemark placemark) => placemark.hashCode == hashCode);

    if (placemark.onTap != null) {
      placemark.onTap!(placemark, point);
    }
  }

  void _onMapSizeChanged(dynamic arguments) {
    if (!_viewRendered) {
      _viewRendered = true;
      _yandexMapState.onMapRendered();
    }

    _yandexMapState.onMapSizeChanged(MapSize(width: arguments['width'], height: arguments['height']));
  }

  void _onCameraPositionChanged(dynamic arguments) {
    _cameraPositionCallback!(arguments);
  }

  Map<String, dynamic> _polylineParams(Polyline polyline) {
    final coordinates = polyline.coordinates.map(
      (Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude}
    ).toList();

    return <String, dynamic>{
      'hashCode': polyline.hashCode,
      'coordinates': coordinates
    }..addAll(_polylineStyleParams(polyline.style));
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
    final outerRingCoordinates = polygon.outerRingCoordinates.map(
      (Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude}
    ).toList();
    final innerRingsCoordinates = polygon.innerRingsCoordinates.map(
      (List<Point> list) {
        return list.map((Point p) => <String, double>{'latitude': p.latitude, 'longitude': p.longitude}).toList();
      }
    ).toList();

    return <String, dynamic>{
      'hashCode': polygon.hashCode,
      'outerRingCoordinates': outerRingCoordinates,
      'innerRingsCoordinates': innerRingsCoordinates
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

  Map<String, dynamic> _circleParams(Circle circle) {

    final center = {'latitude': circle.center.latitude, 'longitude': circle.center.longitude};

    return <String, dynamic>{
      'hashCode': circle.hashCode,
      'center': center,
      'radius': circle.radius,
    }..addAll(_circleStyleParams(circle.style));
  }

  Map<String, dynamic> _circleStyleParams(CircleStyle style) {
    return <String, dynamic>{
      'style': <String, dynamic>{
        'strokeColor': style.strokeColor.value,
        'strokeWidth': style.strokeWidth,
        'fillColor':   style.fillColor.value,
        'isGeodesic':  style.isGeodesic,
      }
    };
  }

  Future<bool> isTiltGesturesEnabled() async {
    final bool value = await _channel.invokeMethod<dynamic>('isTiltGesturesEnabled');
    return value;
  }

  /// Toggles isTiltGesturesEnabled (enable/disable tilt gestures)
  Future<void> toggleTiltGestures({required bool enabled}) async {
    await _channel.invokeMethod<void>('toggleTiltGestures', <String, dynamic>{'enabled': enabled});
  }
}
