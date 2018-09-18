import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

// Time to wait for layout build to finish
final int _kWaitTimeMs = 300;

class YandexMapViewController {
  /// Current `State` of controlled `YandexMapView` widget
  YandexMapViewState widgetState;
  YandexMap yandexMap;

  YandexMapViewController();

  /// Refreshes current mapView
  /// Hides mapView before refreshing
  Future<Null> refresh() async {
    await widgetState.hideMapContainer();
    // Have to wait for layout to finish
    await Future.delayed(Duration(milliseconds: _kWaitTimeMs), () async {
      await widgetState.refreshMapContainer(forceRefresh: true);
    });
  }
}

class YandexMapView extends StatefulWidget {
  /// A `Widget` to show before MapView is shown
  /// By default uses `CircularProgressIndicator`
  final Widget mapPlaceholder;

  /// Will be called each time MapView refreshes its position
  final Function afterMapRefresh;

  final YandexMapViewController controller;

  static void _kAfterMapRefresh() => null;

  /// A `Widget` for displaying Yandex Map
  /// Must be initialized with a `YandexMapView` controller
  const YandexMapView({
    Key key,
    @required this.controller,
    this.mapPlaceholder = const Center(child: CircularProgressIndicator()),
    this.afterMapRefresh = _kAfterMapRefresh
  }) : super(key: key);

  @override
  YandexMapViewState createState() => YandexMapViewState();
}

class YandexMapViewState extends State<YandexMapView> {
  YandexMap yandexMap = YandexMapkit().yandexMap;
  GlobalKey _containerKey = GlobalKey();
  Rect _rect;
  Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.widgetState = this;
    widget.controller.yandexMap = yandexMap;
  }

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
    _setRefreshTimer();

    return Container(
      key: widget.key,
      child: Container(
        key: _containerKey,
        child: widget.mapPlaceholder
      )
    );
  }

  Future<Null> hideMapContainer() async {
    await yandexMap.hide();
  }

  void _setRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(Duration(milliseconds: 300), () async {
      _refreshTimer?.cancel();
      await refreshMapContainer();
    });
  }

  Future<Null> refreshMapContainer({bool forceRefresh: false}) async {
    Rect newRect = _buildRect();

    print(newRect);
    if (_rect != newRect || forceRefresh) {
      _rect = newRect;
      await yandexMap.showResize(_rect);
      widget.afterMapRefresh();
    }

    if (newRect == Rect.zero) {
      _setRefreshTimer();
    }
  }

  Rect _buildRect() {
    // Sometimes findRenderObject can fail
    try {
      RenderObject object = _containerKey.currentContext.findRenderObject();
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
