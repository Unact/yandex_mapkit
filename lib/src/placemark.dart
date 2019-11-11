import 'package:flutter/material.dart';

import 'point.dart';

class Placemark {
  Placemark({
    @required this.point,
    this.opacity = kOpacity,
    this.isDraggable = false,
    this.onTap = _kOnTap,
    this.iconName,
    this.rawImageData,
  });

  final Point point;
  final double opacity;
  final bool isDraggable;
  final String iconName;
  final Function onTap;
  final List<int> rawImageData;

  static const double kOpacity = 0.5;
  static void _kOnTap(double latitude, double longitude) => () { };
}
