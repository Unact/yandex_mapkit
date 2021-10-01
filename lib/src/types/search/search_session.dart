part of yandex_mapkit;

class SearchSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_search_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;
  bool _isClosed = false;

  /// Has the current session been closed
  bool get isClosed => _isClosed;

  SearchSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Cancels running search request if there is one
  ///
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<void> cancel() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('cancel');
  }

  /// Retries last search request(for example if it failed)
  ///
  /// Use all the options of previous request.
  /// Automatically cancels running search if there is one.
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<SearchSessionResult> retry() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    var result = await _methodChannel.invokeMethod('retry');

    return SearchSessionResult._fromJson(result);
  }

  /// Returns true/false depending on if the next page is available
  ///
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<bool> hasNextPage() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    return await _methodChannel.invokeMethod('hasNextPage');
  }

  /// If [SearchResponse.hasNextPage] is false then calling of this method will have no effect
  ///
  /// After [SearchSession.close] has been called, all subsequent calls will return a [SearchSessionException]
  Future<SearchSessionResult> fetchNextPage() async {
    if (_isClosed) {
      throw SearchSessionException._('Session is closed');
    }

    var result = await _methodChannel.invokeMethod('fetchNextPage');

    return SearchSessionResult._fromJson(result);
  }

  /// Closes current session
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

  factory SearchSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return SearchSessionResult._(
      json['found'],
      json['items']?.map<SearchItem>((dynamic item) => SearchItem._fromJson(item)).toList(),
      json['page'],
      json['error']
    );
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
