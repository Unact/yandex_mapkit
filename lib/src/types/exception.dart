part of yandex_mapkit;

class YandexMapkitException implements Exception {}

abstract class SessionException implements Exception {
  final String message;

  SessionException._(this.message);
}
