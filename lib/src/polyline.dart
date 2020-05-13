import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'point.dart';

class Polyline extends Equatable {
  const Polyline({
    @required this.coordinates,
    this.strokeColor = const Color(0xFF0066FF),
    this.strokeWidth = 5.0,
    this.outlineColor = const Color(0x00000000),
    this.outlineWidth = 0.0,
    this.isGeodesic = false,
    this.dashLength = 0.0,
    this.dashOffset = 0.0,
    this.gapLength = 0.0,
  });

  final List<Point> coordinates;

  final Color strokeColor;
  final double strokeWidth;

  final Color outlineColor;
  final double outlineWidth;

  final bool isGeodesic;

  final double dashLength;
  final double dashOffset;
  final double gapLength;

  @override
  List<Object> get props => <Object>[
    coordinates,
    strokeColor,
    strokeWidth,
    outlineColor,
    outlineWidth,
    isGeodesic,
    dashLength,
    dashOffset,
    gapLength,
  ];

  @override
  bool get stringify => true;
}
