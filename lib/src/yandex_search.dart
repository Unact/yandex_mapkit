part of yandex_mapkit;

class YandexSearch {
  static const String _channelName = 'yandex_mapkit/yandex_search';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  static SearchResultWithSession searchByText({
    required String searchText,
    required Geometry geometry,
    required SearchOptions searchOptions
  }) {
    var params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'searchText': searchText,
      'geometry': geometry.toJson(),
      'options': searchOptions.toJson(),
    };
    var result = _channel
      .invokeMethod('searchByText', params)
      .then((result) => SearchSessionResult._fromJson(result));

    return SearchResultWithSession._(
      session: SearchSession._(id: params['sessionId']),
      result: result,
    );
  }

  static SearchResultWithSession searchByPoint({
    required Point point,
    required double zoom,
    required SearchOptions searchOptions
  }) {
    var params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'point': point.toJson(),
      'zoom': zoom,
      'options': searchOptions.toJson(),
    };
    var result = _channel
      .invokeMethod('searchByPoint', params)
      .then((result) => SearchSessionResult._fromJson(result));

    return SearchResultWithSession._(
      session: SearchSession._(id: params['sessionId']),
      result: result,
    );
  }
}
