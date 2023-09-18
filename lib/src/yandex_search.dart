part of yandex_mapkit;

/// Main interface for searching.
class YandexSearch {
  static const String _channelName = 'yandex_mapkit/yandex_search';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSessionId = 0;

  /// Search request for searching a user query near given geometry.
  static SearchResultWithSession searchByText(
      {required String searchText,
      required Geometry geometry,
      required SearchOptions searchOptions}) {
    final params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'searchText': searchText,
      'geometry': geometry.toJson(),
      'searchOptions': searchOptions.toJson(),
    };
    final result = _channel
        .invokeMethod('searchByText', params)
        .then((result) => SearchSessionResult._fromJson(result));

    return SearchResultWithSession._(
      session: SearchSession._(id: params['sessionId']),
      result: result,
    );
  }

  /// Reverse search request (to search objects at the given coordinates)
  static SearchResultWithSession searchByPoint(
      {required Point point, int? zoom, required SearchOptions searchOptions}) {
    final params = <String, dynamic>{
      'sessionId': _nextSessionId++,
      'point': point.toJson(),
      'zoom': zoom,
      'searchOptions': searchOptions.toJson(),
    };
    final result = _channel
        .invokeMethod('searchByPoint', params)
        .then((result) => SearchSessionResult._fromJson(result));

    return SearchResultWithSession._(
      session: SearchSession._(id: params['sessionId']),
      result: result,
    );
  }
}
