part of yandex_mapkit;

class YandexSearch {

  static const String _channelName = 'yandex_mapkit/yandex_search';

  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextSearchSessionId = 0;


  static Future<SearchResponseWithSession> searchByText({
    required  String        searchText,
    required  Geometry      geometry,
    required  SearchOptions searchOptions}) async {

    var sessionId = _nextSearchSessionId++;

    var params = {
      'sessionId':  sessionId,
      'searchText': searchText,
      'geometry':   geometry.toJson(),
      'options':    searchOptions.toJson(),
    };

    var session = SearchSession(id: sessionId);

    final response = _channel.invokeMethod(
      'searchByText',
      params
    ).then((sessionResult) => session.handleResponse(sessionResult));

    return SearchResponseWithSession(
      session: session,
      responseOrError: response,
    );
  }

  static Future<SearchResponseWithSession> searchByPoint({
    required  Point         point,
    required  int           zoom,
    required  SearchOptions searchOptions}) async {

    var sessionId = _nextSearchSessionId++;

    var params = {
      'sessionId':  sessionId,
      'point':      point.toJson(),
      'zoom':       zoom,
      'options':    searchOptions.toJson(),
    };

    var session = SearchSession(id: sessionId);

    final response = _channel.invokeMethod(
        'searchByPoint',
        params
    ).then((sessionResult) => session.handleResponse(sessionResult));

    return SearchResponseWithSession(
      session: session,
      responseOrError: response,
    );
  }
}
