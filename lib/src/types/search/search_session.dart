part of yandex_mapkit;

class SearchSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_search_session_';
  final MethodChannel _methodChannel;

  final int id;
  bool _isClosed = false;

  SearchSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Cancels running search request if there is one.
  ///
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<void> cancel() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Retries last search request (for ex. if it  failed).
  ///
  /// Use all the options of previous request.
  /// Automatically cancels running search if there is one.
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<SearchSessionResult> retry() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    var result = await _methodChannel.invokeMethod('retry');

    return SearchSessionResult.fromJson(result);
  }

  /// Returns true/false depending on next page is available
  ///
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<bool> hasNextPage() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    return await _methodChannel.invokeMethod('hasNextPage');
  }

  /// If hasNextPage in SearchResponse is false
  /// then calling of this method will have no effect.
  ///
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<SearchSessionResult> fetchNextPage() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    var result = await _methodChannel.invokeMethod('fetchNextPage');

    return SearchSessionResult.fromJson(result);
  }

  /// Closes current session.
  /// After close all requests to this session will have no effect.
  ///
  /// After first call, all subsequent calls will return a [SearchSessionException]
  Future<void> close() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('close');

    _isClosed = true;
  }
}

class SearchSessionException extends SessionException {
  SearchSessionException._(String message) : super._(message);
}

class SearchSessionResult {
  final int? found;
  final List<SearchItem>? items;
  final int? page;
  String? error;

  SearchSessionResult._(
    this.found,
    this.items,
    this.page,
    this.error
  );

  factory SearchSessionResult.fromJson(Map<dynamic, dynamic> json) {
    String? error = json['error'];
    List<dynamic>? resultItems = json['items'];
    var items = resultItems?.map((dynamic item) => SearchItem.fromJson(item)).toList();

    return SearchSessionResult._(json['found'], items, json['page'], error);
  }
}

class SearchResultWithSession {
  SearchSession session;
  Future<SearchSessionResult> result;

  SearchResultWithSession._({
    required this.session,
    required this.result
  });
}
