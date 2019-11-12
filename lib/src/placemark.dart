import 'dart:typed_data';

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

  /// Provides ability to use binary image data as Placemark icon.
  ///
  /// You can use this property to assign dynamically generated images as [Placemark icon].
  /// For example:
  /// 
  /// 1) loaded image from network
  /// http.Response response = await http.get('image.url/image.png');
  /// Placemark(rawImageData: response.bodyBytes);
  /// 
  /// 2) or generated image on client side (with Flutter), using dynamic color and icon:
  /// ByteData data = await rootBundle.load(path);
  /// //apply size/color transformations to data, and use it afterwards
  /// Placemark(rawImageData: data.buffer.asUint8List());
  /// 
  /// Examples are only sample pseudo code.
  /// 
  final Uint8List rawImageData;

  static const double kOpacity = 0.5;
  static void _kOnTap(double latitude, double longitude) => () { };
}
