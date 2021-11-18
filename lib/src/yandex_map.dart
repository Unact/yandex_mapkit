part of yandex_mapkit;

class YandexMap extends StatefulWidget {
  /// A `Widget` for displaying Yandex Map
  const YandexMap({
    Key? key,
    this.tiltGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.modelsEnabled = true,
    this.nightModeEnabled = false,
    this.fastTapEnabled = false,
    this.mode2DEnabled = false,
    this.indoorEnabled = false,
    this.liteModeEnabled = false,
    this.onMapCreated,
    this.onMapTap,
    this.onMapLongTap,
    this.onMapSizeChanged,
    this.onUserLocationAdded,
    this.onCameraPositionChanged
  }) : super(key: key);

  static const String viewType = 'yandex_mapkit/yandex_map';

  /// Enable tilt gestures, such as parallel pan with two fingers.
  final bool tiltGesturesEnabled;

  /// Enable rotation gestures, such as rotation with two fingers.
  final bool zoomGesturesEnabled;

  /// Enable rotation gestures, such as rotation with two fingers.
  final bool rotateGesturesEnabled;

  /// Enable/disable zoom gestures, for example: - pinch - double tap (zoom in) - tap with two fingers (zoom out)
  final bool nightModeEnabled;

  /// Enable scroll gestures, such as the pan gesture.
  final bool scrollGesturesEnabled;

  /// Enable removes the 300 ms delay in emitting a tap gesture.
  /// However, a double-tap will emit a tap gesture along with a double-tap.
  final bool fastTapEnabled;

  /// Forces the map to be flat.
  ///
  /// true - All loaded tiles start showing the "flatten out" animation; all new tiles do not start 3D animation.
  /// false - All tiles start showing the "rise up" animation.
  final bool mode2DEnabled;

  /// Enables indoor plans on the map.
  final bool indoorEnabled;

  /// Enables lite rendering mode.
  final bool liteModeEnabled;

  /// Enables detailed 3D models on the map.
  final bool modelsEnabled;

  /// Callback method for when the map is ready to be used.
  ///
  /// Pass to [YandexMap.onMapCreated] to receive a [YandexMapController] when the
  /// map is created.
  final MapCreatedCallback? onMapCreated;

  /// Called every time a [YandexMap] is resized.
  final ArgumentCallback<MapSize>? onMapSizeChanged;

  /// Called every time a [YandexMap] is tapped.
  final ArgumentCallback<Point>? onMapTap;

  /// Called every time a [YandexMap] is long tapped.
  final ArgumentCallback<Point>? onMapLongTap;

  /// Called every time when the camera position on [YandexMap] is changed.
  final CameraPositionCallback? onCameraPositionChanged;

  /// Callback to be called when a user location layer icon elements have been added to [YandexMap].
  ///
  /// Use this method if you want to change how users current position is displayed
  /// You can return [UserLocationView] with changed [UserLocationView.pin], [UserLocationView.arrow],
  /// [UserLocationView.accuracyCircle] to change how it is shown on the map.
  ///
  /// This is called only once when the layer is made visible for the first time
  final UserLocationCallback? onUserLocationAdded;

  @override
  _YandexMapState createState() => _YandexMapState();
}

class _YandexMapState extends State<YandexMap> {
  late _YandexMapOptions _yandexMapOptions;

  final Completer<YandexMapController> _controller =
      Completer<YandexMapController>();

  @override
  void initState() {
    super.initState();
    _yandexMapOptions = _YandexMapOptions.fromWidget(widget);
  }

  @override
  void dispose() async {
    super.dispose();
    final controller = await _controller.future;

    controller.dispose();
  }

  void _updateOptions() async {
    final newOptions = _YandexMapOptions.fromWidget(widget);
    final updates = _yandexMapOptions.mapUpdates(newOptions);

    if (updates.isEmpty) {
      return;
    }

    final controller = await _controller.future;

    await controller._updateMapOptions(updates);
    _yandexMapOptions = newOptions;
  }

  @override
  void didUpdateWidget(YandexMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        },
        creationParamsCodec: StandardMessageCodec(),
        creationParams: _yandexMapOptions.toJson(),
      );
    } else {
      return UiKitView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        },
        creationParamsCodec: StandardMessageCodec(),
        creationParams: _yandexMapOptions.toJson(),
      );
    }
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final controller = await YandexMapController.init(id, this);

    _controller.complete(controller);

    if (widget.onMapCreated != null) {
      widget.onMapCreated!(controller);
    }
  }
}

/// Configuration options for the YandexMap native view.
class _YandexMapOptions {
  _YandexMapOptions.fromWidget(YandexMap map) :
    tiltGesturesEnabled = map.tiltGesturesEnabled,
    zoomGesturesEnabled = map.zoomGesturesEnabled,
    rotateGesturesEnabled = map.rotateGesturesEnabled,
    scrollGesturesEnabled = map.scrollGesturesEnabled,
    modelsEnabled = map.modelsEnabled,
    nightModeEnabled = map.nightModeEnabled,
    fastTapEnabled = map.fastTapEnabled,
    mode2DEnabled = map.mode2DEnabled,
    indoorEnabled = map.indoorEnabled,
    liteModeEnabled = map.liteModeEnabled;

    final bool tiltGesturesEnabled;

    final bool zoomGesturesEnabled;

    final bool rotateGesturesEnabled;

    final bool nightModeEnabled;

    final bool scrollGesturesEnabled;

    final bool fastTapEnabled;

    final bool mode2DEnabled;

    final bool indoorEnabled;

    final bool liteModeEnabled;

    final bool modelsEnabled;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tiltGesturesEnabled': tiltGesturesEnabled,
      'zoomGesturesEnabled': zoomGesturesEnabled,
      'rotateGesturesEnabled': rotateGesturesEnabled,
      'nightModeEnabled': nightModeEnabled,
      'scrollGesturesEnabled': scrollGesturesEnabled,
      'fastTapEnabled': fastTapEnabled,
      'mode2DEnabled': mode2DEnabled,
      'indoorEnabled': indoorEnabled,
      'liteModeEnabled': liteModeEnabled,
      'modelsEnabled': modelsEnabled,
    };
  }

  Map<String, dynamic> mapUpdates(_YandexMapOptions newOptions) {
    final prevOptionsMap = toJson();

    return newOptions.toJson()..removeWhere((String key, dynamic value) => prevOptionsMap[key] == value);
  }
}
