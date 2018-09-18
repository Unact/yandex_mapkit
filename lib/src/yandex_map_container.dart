import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapContainer extends StatefulWidget {

  /// A `Widget` to show before MapView is shown
  /// By default uses `CircularProgressIndicator`
  final Widget mapPlaceholder;

  /// Will be called each time MapView refreshes its position
  final Function afterMapRefresh;

  static void _kAfterMapRefresh(YandexMap yandexMap) => null;

  /// A `Widget` for displaying Yandex Map
  const YandexMapContainer({
    Key key,
    this.mapPlaceholder = const Center(child: CircularProgressIndicator()),
    this.afterMapRefresh = _kAfterMapRefresh
  }) : super(key: key);

  @override
  _YandexMapContainerState createState() => _YandexMapContainerState();
}

class _YandexMapContainerState extends State<YandexMapContainer> {
  YandexMap _yandexMap = YandexMapkit().yandexMap;
  GlobalKey _containerKey = GlobalKey();
  Rect _rect;
  Timer _refreshTimer;

  @override
  void reassemble() {
    super.reassemble();

    _refreshMapContainer();
  }

  @override
  void deactivate() {
    super.deactivate();

    _yandexMap.reset();
  }

  @override
  void dispose() {
    super.dispose();

    _yandexMap.reset();
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

  void _setRefreshTimer() {
    _refreshTimer = Timer(Duration(milliseconds: 100), () async {
      _refreshTimer?.cancel();
      await _refreshMapContainer();
    });
  }

  Future<Null> _refreshMapContainer() async {
    Rect newRect = _buildRect();

    if (_rect != newRect) {
      _rect = newRect;
      await _yandexMap.showResize(_rect);
      widget.afterMapRefresh(_yandexMap);
    }

    if (newRect == Rect.zero) {
      _setRefreshTimer();
    }
  }

  Rect _buildRect() {
    // Sometimes findRenderObject may fail
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
