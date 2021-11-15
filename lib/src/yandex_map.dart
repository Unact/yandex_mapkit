part of yandex_mapkit;

class YandexMap extends StatefulWidget {
  /// A `Widget` for displaying Yandex Map
  const YandexMap({
    Key? key,
    this.onMapCreated,
    this.onMapTap,
    this.onMapLongTap,
    this.onMapSizeChanged,
    this.onUserLocationAdded
  }) : super(key: key);

  static const String viewType = 'yandex_mapkit/yandex_map';

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
  late YandexMapController _controller;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        },
      );
    } else {
      return UiKitView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        },
      );
    }
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _controller = await YandexMapController.init(id, this);

    if (widget.onMapCreated != null) {
      widget.onMapCreated!(_controller);
    }
  }
}
