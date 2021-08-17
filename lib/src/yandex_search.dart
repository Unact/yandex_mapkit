part of yandex_mapkit;

class YandexSearch {
  static const String _channelName = 'yandex_mapkit/yandex_search';

  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextCallbackId = 0;

  static Future<SuggestSession> getSuggestions({
    required String address,
    required Point southWestPoint,
    required Point northEastPoint,
    required SuggestType suggestType,
    required bool suggestWords,
  }) async {
    final listenerId = _nextCallbackId++;

    final futureResult =
        _channel.invokeMethod('getSuggestions', <String, dynamic>{
      'formattedAddress': address,
      'southWestLatitude': southWestPoint.latitude,
      'southWestLongitude': southWestPoint.longitude,
      'northEastLatitude': northEastPoint.latitude,
      'northEastLongitude': northEastPoint.longitude,
      'suggestType': suggestType.index,
      'suggestWords': suggestWords,
      'listenerId': listenerId
    }).then((it) => SuggestSessionResult.fromJson(it));

    return SuggestSession(
        futureResult, () => _cancelSuggestSession(listenerId));
  }

  static Future<void> _cancelSuggestSession(int listenerId) async {
    await _channel.invokeMethod<void>(
      'cancelSuggestSession',
      <String, dynamic>{'listenerId': listenerId},
    );
  }
}
