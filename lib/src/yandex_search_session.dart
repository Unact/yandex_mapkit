part of yandex_mapkit;

class SearchSession {

  static const String _methodChannelName = 'yandex_mapkit/yandex_search_session_';

  final MethodChannel _methodChannel;

  final int id;

  SearchSession({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Cancels running search request if there is one.
  /// Do nothing if there are no active searches.
  Future<void> cancelSearch() async {

    await _methodChannel.invokeMethod<void>('cancelSearch');
  }

  /// Retries last search request (for ex. if it  failed).
  /// Use all the options of previous request.
  /// Automatically cancels running search if there is one.
  Future<SearchResponseOrError> retrySearch() async {

    return _methodChannel.invokeMethod('retrySearch').then((response) => handleResponse(response));
  }

  /// Returns true/false depending on next page is available
  Future<bool> hasNextPage() async {

    return await _methodChannel.invokeMethod('hasNextPage');
  }

  /// If hasNextPage in SearchResponse is false
  /// then calling of this method will have no effect.
  Future<SearchResponseOrError> fetchNextPage() async {

    return _methodChannel.invokeMethod('fetchNextPage').then((response) => handleResponse(response));
  }

  /// Closes current session.
  /// After close all requests to this session will have no effect.
  Future<void> close() async {

    await _methodChannel.invokeMethod<void>('close');
  }

  SearchResponseOrError handleResponse(dynamic arguments) {

    if (arguments['error'] != null) {

      return SearchResponseOrError(
        error: arguments['error']
      );

    } else {

      final Map<dynamic, dynamic> response = arguments['response'];

      return SearchResponseOrError(
        response: SearchResponse.fromJson(response),
      );
    }
  }
}