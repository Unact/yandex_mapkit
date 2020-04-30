import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Point extends Equatable{
  const Point({
    @required this.latitude, 
    @required this.longitude
  });

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => <Object>[
    latitude,
    longitude
  ];

  @override
  bool get stringify => true;
}
