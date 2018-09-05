import 'dart:async';

import 'package:flutter/services.dart';

class YandexMapkit {
  static const MethodChannel _channel =
      const MethodChannel('yandex_mapkit');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
