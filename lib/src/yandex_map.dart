import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'yandex_map_controller.dart';

class YandexMap extends StatefulWidget {
  /// A `Widget` for displaying Yandex Map
  const YandexMap({
    Key key,
    this.onMapCreated
  }) : super(key: key);

  static const String viewType = 'yandex_mapkit/yandex_map';

  final Function onMapCreated;

  @override
  YandexMapState createState() => YandexMapState();
}

class YandexMapState extends State<YandexMap> {
  YandexMapController _controller;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        ].toSet(),
      );
    } else {
      return UiKitView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        ].toSet(),
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    _controller = YandexMapController.init(id);

    if (widget.onMapCreated != null) {
      widget?.onMapCreated(_controller);
    }
  }
}
