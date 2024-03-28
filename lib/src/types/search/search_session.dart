part of '../../../yandex_mapkit.dart';

/// Defines a started search request
class SearchSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_search_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;

  SearchSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Cancels running search request if there is one
  Future<void> cancel() async {
    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Retries last search request(for example if it failed)
  ///
  /// Use all the options of previous request.
  /// Automatically cancels running search if there is one.
  Future<SearchSessionResult> retry() async {
    final result = await _methodChannel.invokeMethod('retry');

    return SearchSessionResult._fromJson(result);
  }

  /// Returns true/false depending on if the next page is available
  Future<bool> hasNextPage() async {
    return await _methodChannel.invokeMethod('hasNextPage');
  }

  /// If [SearchResponse.hasNextPage] is false then calling of this method will have no effect
  Future<SearchSessionResult> fetchNextPage() async {
    final result = await _methodChannel.invokeMethod('fetchNextPage');

    return SearchSessionResult._fromJson(result);
  }

  /// Closes current session
  Future<void> close() async {
    await _methodChannel.invokeMethod<void>('close');
  }

  /// Starts text search session
  Future<SearchSessionResult> _searchByText({
    required String searchText,
    required Geometry geometry,
    required SearchOptions searchOptions
  }) async {
    final params = <String, dynamic>{
      'searchText': searchText,
      'geometry': geometry.toJson(),
      'searchOptions': searchOptions.toJson(),
    };

    final result = await _methodChannel.invokeMethod('searchByText', params);

    return SearchSessionResult._fromJson(result);
  }

  /// Starts point search session
  Future<SearchSessionResult> _searchByPoint({
    required Point point,
    int? zoom,
    required SearchOptions searchOptions
  }) async {
    final params = <String, dynamic>{
      'point': point.toJson(),
      'zoom': zoom,
      'searchOptions': searchOptions.toJson(),
    };

    final result = await _methodChannel.invokeMethod('searchByPoint', params);

    return SearchSessionResult._fromJson(result);
  }
}

/// Result of a search request
/// If any errors have occured then [items], [found], [page] will be empty, otherwise [error] will be empty
class SearchSessionResult {

  /// Total count of found items
  final int? found;

  /// Result items from the first page
  final List<SearchItem>? items;

  /// Number of pages of results
  final int? page;

  /// Error message
  String? error;

  SearchSessionResult._(
    this.found,
    this.items,
    this.page,
    this.error
  );

  factory SearchSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return SearchSessionResult._(
      json['found'],
      json['items']?.map<SearchItem>((dynamic item) => SearchItem._fromJson(item)).toList(),
      json['page'],
      json['error']
    );
  }
}
