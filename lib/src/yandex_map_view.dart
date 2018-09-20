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

  /// Refreshes current mapView
  /// Hides mapView before refreshing
  Future<Null> refresh() async {
    await _hideMapContainer();
    // Have to wait for layout to finish
    await Future.delayed(Duration(milliseconds: _kWaitTimeMs), () async {
      await _refreshMapContainer(forceRefresh: true);
    });
  }

  Future<Null> _hideMapContainer() async {
    await yandexMap.hide();
  }

  Future<Null> _refreshMapContainer({bool forceRefresh: false}) async {
    Rect newRect = _buildRect();

    if (_rect != newRect || forceRefresh) {
      _rect = newRect;
      await yandexMap.showResize(_rect);
      widget.afterMapRefresh();
    }
  }

  Rect _buildRect() {
    // Sometimes findRenderObject can fail
    try {
      RenderObject object = context.findRenderObject();
      Vector3 translation = object.getTransformTo(null).getTranslation();
      Size size = object.semanticBounds.size;

      if (translation.x >= 0 && translation.y >= 0) {
        return Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
      } else {
        return Rect.zero;
      }
    } catch(e) {
      return Rect.zero;
    }
  }
}
