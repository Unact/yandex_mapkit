import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapContainer extends StatefulWidget {
  final List<Placemark> placemarks;

  /// A `Widget` to show before MapView is shown
  /// By default uses `CircularProgressIndicator`
  final Widget mapPlaceholder;

  final Function afterMapShow;

  static void _kAfterMapShow(YandexMap yandexMap) => null;

  /// A `Widget` for displaying Yandex Map
  const YandexMapContainer({
    Key key,
    this.placemarks = const [],
    this.mapPlaceholder = const CircularProgressIndicator(),
    this.afterMapShow = _kAfterMapShow
  }) : super(key: key);

  @override
  _YandexMapContainerState createState() => _YandexMapContainerState();
}

class _YandexMapContainerState extends State<YandexMapContainer> {
  YandexMap _yandexMap = YandexMapkit().yandexMap;
  GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _setMapRefresh();
  }

  @override
  void reassemble() {
    _setMapRefresh();

    super.reassemble();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _yandexMap.reset();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      child: Container(
        key: _containerKey,
        child: Center(child: widget.mapPlaceholder)
      )
    );
  }

  void _setMapRefresh() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _yandexMap.reset();
      await _yandexMap.addPlacemarks(widget.placemarks);
      await _yandexMap.showFitRect(_buildRect());

      widget.afterMapShow(_yandexMap);
    });
  }

  Rect _buildRect() {
    RenderObject object = _containerKey.currentContext.findRenderObject();
    Vector3 translation = object.getTransformTo(null).getTranslation();
    Size size = object.semanticBounds.size;

    return Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
  }
}
