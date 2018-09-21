import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapView extends StatefulWidget {
  /// A `Widget` to show before MapView is shown
  /// By default uses `CircularProgressIndicator`
  final Widget mapPlaceholder;

  /// Will be called each time MapView refreshes its position
  final Function afterMapRefresh;

  static void _kAfterMapRefresh() => null;

  /// A `Widget` for displaying Yandex Map
  const YandexMapView({
    Key key,
    this.mapPlaceholder = const Center(child: CircularProgressIndicator()),
    this.afterMapRefresh = _kAfterMapRefresh
  }) : super(key: key);

  @override
  YandexMapViewState createState() => YandexMapViewState();
}

class YandexMapViewState extends State<YandexMapView> {
  // Time to wait for layout build to finish
  final int _kWaitTimeMs = 500;
  bool _hidden = true;
  YandexMap yandexMap = YandexMapkit().yandexMap;
  Rect _rect;

  @override
  void deactivate() {
    super.deactivate();

    yandexMap.reset();
  }

  @override
  void dispose() {
    super.dispose();

    yandexMap.reset();
  }

  @override
  Widget build(BuildContext context) {
    _refreshMapContainer();

    return widget.mapPlaceholder;
  }

  Future<Null> hide() async {
    await _hideMapContainer();
  }

  Future<Null> show() async {
    await _showMapContainer();
  }

  /// Refreshes current mapView
  /// Always shows mapView
  Future<Null> refresh() async {
    _refreshMapContainerDelayed();
  }

  Future<Null> _hideMapContainer({bool force: false}) async {
    if (_hidden && !force) return;

    _hidden = true;
    await yandexMap.hide();
  }

  Future<Null> _showMapContainer({bool force: false}) async {
    if (!_hidden && !force) return;

    _hidden = false;
    await yandexMap.show();
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
      await yandexMap.resize(_rect);
      await _showMapContainer(force: true);
      widget.afterMapRefresh();
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
