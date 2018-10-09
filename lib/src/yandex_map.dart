import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'yandex_map_controller.dart';

class YandexMap extends StatefulWidget {
  /// Only for `iOS`
  /// A `Widget` to show before MapView is shown
  /// By default uses `CircularProgressIndicator`
  final Widget mapPlaceholder;

  /// On `Android` will be called only once
  /// On `iOS` will be called each time native MapView refreshes its position
  final Function onMapCreated;

  static void _kOnMapCreated(YandexMapController controller) => null;

  /// A `Widget` for displaying Yandex Map
  const YandexMap({
    Key key,
    this.mapPlaceholder = const Center(child: CircularProgressIndicator()),
    this.onMapCreated = _kOnMapCreated,
  }) : super(key: key);

  @override
  YandexMapState createState() => YandexMapState();
}

class YandexMapState extends State<YandexMap> {
  // Time to wait for layout build to finish
  final int _kWaitTimeMs = 500;
  bool _hidden = true;
  Rect _rect;
  YandexMapController _controller;

  @override
  void deactivate() {
    super.deactivate();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _controller?.reset();
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _controller?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'yandex_mapkit/yandex_map',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: [
          VerticalDragGestureRecognizer(),
          HorizontalDragGestureRecognizer()
        ],
      );
    }

    _refreshMapContainer();

    return widget.mapPlaceholder;
  }

  void _onPlatformViewCreated(int id) {
    _controller = YandexMapController.init(id, defaultTargetPlatform);
    widget.onMapCreated(_controller);
  }

  /// Shows mapView
  /// Works only on `TargetPlatform.iOS`
  Future<Null> hide() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _hideMapContainer();
    }
  }

  /// Shows mapView
  /// Works only on `TargetPlatform.iOS`
  Future<Null> show() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _showMapContainer();
    }
  }

  /// Refreshes current mapView
  /// Always shows mapView
  /// Works only on `TargetPlatform.iOS`
  Future<Null> refresh() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _refreshMapContainerDelayed();
    }
  }

  Future<Null> _hideMapContainer({bool force: false}) async {
    if (_hidden && !force) return;

    _hidden = true;
    await _controller.hide();
  }

  Future<Null> _showMapContainer({bool force: false}) async {
    if (!_hidden && !force) return;

    _hidden = false;
    await _controller.show();
  }

  /// Waiting for layout to finish
  Future<Null> _refreshMapContainerDelayed() async {
    await Future.delayed(Duration(milliseconds: _kWaitTimeMs), () async {
      await _refreshMapContainer(force: true);
    });
  }

  Future<Null> _refreshMapContainer({bool force: false}) async {
    Rect newRect = _buildRect();

    if (newRect == null) {
      _refreshMapContainerDelayed();
      return;
    }

    if (_rect != newRect || force) {
      _rect = newRect;
      _controller = YandexMapController.init(null, defaultTargetPlatform);
      await _controller.reset();
      await _controller.resize(_rect);
      await _showMapContainer(force: true);
      widget.onMapCreated(_controller);
    }
  }

  Rect _buildRect() {
    // Sometimes findRenderObject can fail
    try {
      RenderBox box = context.findRenderObject();
      Vector3 translation = box.getTransformTo(null).getTranslation();
      Size size = box.semanticBounds.size;

      if (translation.x >= 0 && translation.y >= 0) {
        return Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
      } else {
        return Rect.zero;
      }
    } catch(e) {
      return null;
    }
  }
}
