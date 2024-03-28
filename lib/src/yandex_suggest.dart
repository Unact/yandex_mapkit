part of '../yandex_mapkit.dart';

/// Interface for text suggestions.
class YandexSuggest {
  static const String _channelName = 'yandex_mapkit/yandex_suggest';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextId = 0;

  /// Get suggestions for text
  static Future<(SuggestSession, Future<SuggestSessionResult>)> getSuggestions({
    required String text,
    required BoundingBox boundingBox,
    required SuggestOptions suggestOptions
  }) async {
    final session = await _initSession();

    return (session, session._getSuggestions(text: text, boundingBox: boundingBox, suggestOptions: suggestOptions));
  }

  /// Initialize session on native side for further use
  static Future<SuggestSession> _initSession() async {
    final id = _nextId++;

    await _channel.invokeMethod('initSession', { 'id': id });

    return SuggestSession._(id: id);
  }
}
