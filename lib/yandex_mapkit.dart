library yandex_map;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'src/map_animation.dart';
export 'src/placemark.dart';
export 'src/point.dart';
export 'src/yandex_map.dart';
export 'src/yandex_map_controller.dart';

/// Singleton Class for accessing Yandex MapView
/// To initialize use `setup`
/// To communicate with MapView use `map` property
class YandexMapkit {
  /// Initializes native Yandex MapView
  static Future<void> setup({@required String apiKey}) async {
    await MethodChannel('yandex_mapkit').invokeMethod('setApiKey', apiKey);
  }
}
