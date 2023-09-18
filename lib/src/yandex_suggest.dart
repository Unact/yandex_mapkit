part of yandex_mapkit;

/// Interface for text suggestions.
class YandexSuggest {
  static const String _channelName = 'yandex_mapkit/yandex_suggest';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  /// Get suggestions for text
  static SuggestResultWithSession getSuggestions(
      {required String text,
      required BoundingBox boundingBox,
      required SuggestOptions suggestOptions}) {
    final params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'text': text,
      'boundingBox': boundingBox.toJson(),
      'suggestOptions': suggestOptions.toJson(),
    };
    final result = _channel
        .invokeMethod('getSuggestions', params)
        .then((result) => SuggestSessionResult._fromJson(result));

    return SuggestResultWithSession._(
        session: SuggestSession._(id: params['sessionId']), result: result);
  }
}
