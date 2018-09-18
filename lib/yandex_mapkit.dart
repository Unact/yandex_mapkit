library yandex_map;

import 'dart:async';

import 'package:flutter/material.dart';

import 'src/yandex_map.dart';

export 'src/map_animation.dart';
export 'src/placemark.dart';
export 'src/point.dart';
export 'src/yandex_map_view.dart';
export 'src/yandex_map.dart';

/// Singleton Class for accessing Yandex MapView
/// To initialize use `setup`
/// To communicate with MapView use `map` property
class YandexMapkit {
  YandexMap yandexMap;
  static YandexMapkit _instance;

  factory YandexMapkit() => _instance;

  YandexMapkit._({@required this.yandexMap});

  /// Initializes Yandex MapView for future use
  static Future<YandexMapkit> setup({@required String apiKey}) async {
    _instance = YandexMapkit._(yandexMap: await YandexMap.init(apiKey: apiKey));
    return _instance;
  }
}
