part of yandex_mapkit;

class SearchSession {

  static const String _methodChannelName = 'yandex_mapkit/yandex_search_session_';
  static const String _eventChannelName  = 'yandex_mapkit/yandex_search_session_events_';

  final MethodChannel _methodChannel;
  final EventChannel  _eventChannel;

  final int id;

  late Future<SearchResponseOrError> lastResponse;
  Completer<SearchResponseOrError> _responseCompleter;

  SearchSession({required this.id}) :
        _methodChannel = MethodChannel(_methodChannelName + id.toString()),
        _eventChannel = EventChannel(_eventChannelName + id.toString()),
        _responseCompleter = Completer<SearchResponseOrError>() {

    _eventChannel.receiveBroadcastStream().listen(_onResponse, onError: _onError);

    lastResponse = _responseCompleter.future;
  }

  /// Cancels running search request if there is one.
  /// Do nothing if there are no active searches.
  Future<void> cancelSearch() async {

    await _methodChannel.invokeMethod<void>('cancelSearch');
  }

  /// Retries last search request (for ex. if it  failed).
  /// Use all the options of previous request.
  /// Automatically cancels running search if there is one.
  Future<SearchResponseOrError> retrySearch() async {

    await _methodChannel.invokeMethod<void>('retrySearch');

    _responseCompleter = Completer<SearchResponseOrError>();

    lastResponse = _responseCompleter.future;

    return lastResponse;
  }

  /// If hasNextPage in SearchResponse is false
  /// then calling of this method will have no effect.
  Future<SearchResponseOrError> fetchNextPage() async {

    await _methodChannel.invokeMethod<void>('fetchNextPage');

    _responseCompleter = Completer<SearchResponseOrError>();

    lastResponse = _responseCompleter.future;

    return lastResponse;
  }

  /// Closes current session.
  /// After close all requests to this session will have no effect.
  Future<void> close() async {

    await _methodChannel.invokeMethod<void>('close');
  }

  void _onResponse(dynamic arguments) {

    final Map<dynamic, dynamic> response = arguments['response'];

    final respObj = SearchResponseOrError(
      response: SearchResponse.fromJson(response),
      error: null
    );

    _responseCompleter.complete(respObj);
  }

  void _onError(dynamic arguments) {

    final String errorMessage = arguments['message'];

    final respObj = SearchResponseOrError(
        response: null,
        error: errorMessage
    );

    _responseCompleter.complete(respObj);
  }
}