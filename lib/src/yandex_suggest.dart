part of yandex_mapkit;

class YandexSuggest {
  static const String _channelName = 'yandex_mapkit/yandex_suggest';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  static SuggestResultWithSession getSuggestions({
    required String address,
    required Point southWestPoint,
    required Point northEastPoint,
    required SuggestType suggestType,
    required bool suggestWords,
  }) {
    var params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'formattedAddress': address,
      'southWestLatitude': southWestPoint.latitude,
      'southWestLongitude': southWestPoint.longitude,
      'northEastLatitude': northEastPoint.latitude,
      'northEastLongitude': northEastPoint.longitude,
      'suggestType': suggestType.value,
      'suggestWords': suggestWords,
    };
    var result = _channel
      .invokeMethod('getSuggestions', params)
      .then((result) => SuggestSessionResult.fromJson(result));

    return SuggestResultWithSession._(
      session: SuggestSession._(id: params['sessionId']),
      result: result
    );
  }
}
