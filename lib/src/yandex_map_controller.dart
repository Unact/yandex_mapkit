import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'map_animation.dart';
import 'placemark.dart';
import 'point.dart';

class YandexMapController extends ChangeNotifier {
  static const double kTilt = 0.0;
  static const double kAzimuth = 0.0;
  static const double kZoom = 15.0;

  final MethodChannel _channel;

  final List<Placemark> placemarks = [];

  final int _id;

  final TargetPlatform _targetPlatform;

  YandexMapController._(this._id, this._targetPlatform,  channel)
      : _channel = channel {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static YandexMapController init(int id, TargetPlatform targetPlatform) {
    final MethodChannel methodChannel = MethodChannel('yandex_mapkit/yandex_map_${id != null ? id : 'ios'}');

    return YandexMapController._(id, targetPlatform, methodChannel);
  }

  /// Returns map to the default state
  /// 1. Removes all placemarks
  /// 2. Hides map
  /// 3. Set MapView size to a 0,0,0,0 sized rectangle
  Future<Null> reset() async {
    if (_targetPlatform == TargetPlatform.android) {
      throw UnimplementedError;
    }

    await _channel.invokeMethod('reset');
  }

  /// Resizes native view
  /// Works only on `TargetPlatform.iOS`
  Future<Null> resize(Rect rect) async {
    if (_targetPlatform == TargetPlatform.android) {
      throw UnimplementedError;
    }

    await _channel.invokeMethod('resize', _rectParams(rect));
  }

  /// Shows native view
  /// Works only on `TargetPlatform.iOS`
  Future<Null> show() async {
    if (_targetPlatform == TargetPlatform.android) {
      throw UnimplementedError;
    }

    await _channel.invokeMethod('show');
  }

  /// Hides native view
  /// Works only on `TargetPlatform.iOS`
  Future<Null> hide() async {
    if (_targetPlatform == TargetPlatform.android) {
      throw UnimplementedError;
    }

    await _channel.invokeMethod('hide');
  }

  /// Shows an icon at current user location
  ///
  /// Requires location permissions:
  ///
  /// `NSLocationWhenInUseUsageDescription`
  ///
  /// `android.permission.ACCESS_FINE_LOCATION`
  ///
  /// Does nothing if these permissions where denied
  Future<Null> showUserLayer({@required String iconName}) async {
    await _channel.invokeMethod(
      'showUserLayer',
      {
        'iconName': iconName
      }
    );
  }

  /// Hides an icon at current user location
  ///
  /// Requires location permissions:
  ///
  /// `NSLocationWhenInUseUsageDescription`
  ///
  /// `android.permission.ACCESS_FINE_LOCATION`
  ///
  /// Does nothing if these permissions where denied
  Future<Null> hideUserLayer() async {
    await _channel.invokeMethod('hideUserLayer');
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

  /// Does nothing if passed `Placemark` is `null`
  Future<Null> addPlacemark(Placemark placemark) async {
    if (placemark != null) {
      await _channel.invokeMethod('addPlacemark', _placemarkParams(placemark));
      placemarks.add(placemark);
    }
  }

  // Does nothing if passed `Placemark` wasn't added before
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

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onMapObjectTap':
        _onMapObjectTap(call.arguments);
        break;
      default:
        throw MissingPluginException();
    }
  }

  void _onMapObjectTap(dynamic arguments) {
    int hashCode = arguments['hashCode'];
    double latitude = arguments['latitude'];
    double longitude = arguments['longitude'];

    Placemark placemark = placemarks.
      firstWhere((Placemark placemark) => placemark.hashCode == hashCode, orElse: () => null);

    if (placemark != null) {
      placemark.onTap(latitude, longitude);
    }
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
