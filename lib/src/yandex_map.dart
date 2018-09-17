import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'map_animation.dart';
import 'placemark.dart';
import 'point.dart';

class YandexMap {
  static const MethodChannel _channel = MethodChannel('yandex_mapkit');
  static const double kTilt = 0.0;
  static const double kAzimuth = 0.0;
  static const double kZoom = 15.0;

  final List<Placemark> placemarks = [];

  YandexMap._() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  /// Initializes MapView
  /// If MapView was initialized before it will be reset
  static Future<YandexMap> init({@required String apiKey}) async {
    YandexMap yandexMap = YandexMap._();
    await yandexMap._setApiKey(apiKey);
    await yandexMap.reset();

    return yandexMap;
  }

  Future<Null> _setApiKey(String apiKey) async {
    await _channel.invokeMethod('setApiKey', apiKey);
  }

  Future<Null> hide() async {
    await _channel.invokeMethod('hide');
  }

  Future<Null> move({
    @required Point point,
    double zoom = kZoom,
    double azimuth = kAzimuth,
    double tilt = kTilt,
    MapAnimation animation
  }) async {
    await _channel.invokeMethod(
      'move',
      {
        'latitude': point.latitude,
        'longitude': point.longitude,
        'zoom': zoom,
        'azimuth': azimuth,
        'tilt': tilt,
        'animate': animation != null,
        'smoothAnimation': animation?.smooth,
        'animationDuration': animation?.duration
      }
    );
  }

  /// Returns map to the default state
  /// 1. Removes all placemarks
  /// 2. Hides map
  /// 3. Set MapView size to a 0,0,0,0 sized rectangle
  Future<Null> reset() async {
    await _channel.invokeMethod('reset');
    _resetLocal();
  }

  void _resetLocal() {
    _removePlacemarksLocal();
  }

  Future<Null> resize(Rect rect) async {
    await _channel.invokeMethod('resize', _rectParams(rect));
  }

  Future<Null> show() async {
    await _channel.invokeMethod('show');
  }

  Future<Null> showFitRect(Rect rect) async {
    await _channel.invokeMethod('showFitRect', _rectParams(rect));
  }

  Future<Null> setBounds({
    @required Point southWestPoint,
    @required Point northEastPoint,
    MapAnimation animation
  }) async {
    await _channel.invokeMethod(
      'setBounds',
      {
        'southWestLatitude': southWestPoint.latitude,
        'southWestLongitude': southWestPoint.longitude,
        'northEastLatitude': northEastPoint.latitude,
        'northEastLongitude': northEastPoint.longitude,
        'animate': animation != null,
        'smoothAnimation': animation?.smooth,
        'animationDuration': animation?.duration
      }
    );
  }

  Future<Null> addPlacemark(Placemark placemark) async {
    await _channel.invokeMethod('addPlacemark', _placemarkParams(placemark));
    _addPlacemarksLocal([placemark]);
  }

  Future<Null> addPlacemarks(List<Placemark> newPlacemarks) async {
    await _channel.invokeMethod(
      'addPlacemarks',
      newPlacemarks.map((Placemark placemark) => _placemarkParams(placemark)).toList()
    );
    _addPlacemarksLocal(newPlacemarks);
  }

  void _addPlacemarksLocal(List<Placemark> newPlacemarks) {
    placemarks.addAll(newPlacemarks);
  }

  Future<Null> removePlacemark(Placemark placemark) async {
    if (placemarks.remove(placemark)) {
      await _channel.invokeMethod(
        'removePlacemark',
        {
          'hashCode': placemark.hashCode
        }
      );
    }
  }

  Future<Null> removePlacemarks() async {
    await _channel.invokeMethod('removePlacemarks');
    _removePlacemarksLocal();
  }

  void _removePlacemarksLocal() {
    placemarks.removeRange(0, placemarks.length);
  }

  Future<dynamic> _handleMethod(MethodCall methodCall) async {
    switch(methodCall.method) {
      case 'onMapObjectTap':
        _onMapObjectTap(methodCall.arguments);
        break;
    }
  }

  void _onMapObjectTap(dynamic arguments) {
    int hashCode = arguments['hashCode'];
    double latitude = arguments['latitude'];
    double longitude = arguments['longitude'];

    placemarks.firstWhere((Placemark placemark) => placemark.hashCode == hashCode).onTap(latitude, longitude);
  }

  Map<String, double> _rectParams(Rect rect) {
    return {
      'left': rect.left,
      'top': rect.top,
      'width': rect.width,
      'height': rect.height
    };
  }

  Map<String, dynamic> _placemarkParams(Placemark placemark) {
    return {
      'latitude': placemark.point.latitude,
      'longitude': placemark.point.longitude,
      'opacity': placemark.opacity,
      'isDraggable': placemark.isDraggable,
      'iconName': placemark.iconName,
      'hashCode': placemark.hashCode
    };
  }
}
