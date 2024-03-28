part of '../yandex_mapkit.dart';

/// Main interface for searching.
class YandexSearch {
  static const String _channelName = 'yandex_mapkit/yandex_search';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static int _nextId = 0;

  /// Search request for searching a user query near given geometry.
  static Future<(SearchSession, Future<SearchSessionResult>)> searchByText({
    required String searchText,
    required Geometry geometry,
    required SearchOptions searchOptions
  }) async {
    final session = await _initSession();

    return (session, session._searchByText(searchText: searchText, geometry: geometry, searchOptions: searchOptions));
  }

  /// Reverse search request (to search objects at the given coordinates)
  static Future<(SearchSession, Future<SearchSessionResult>)> searchByPoint({
    required Point point,
    int? zoom,
    required SearchOptions searchOptions
  }) async {
    final session = await _initSession();

    return (session, session._searchByPoint(point: point, searchOptions: searchOptions));
  }

  /// Initialize session on native side for further use
  static Future<SearchSession> _initSession() async {
    final id = _nextId++;

    await _channel.invokeMethod('initSession', { 'id': id });

    return SearchSession._(id: id);
  }
}
