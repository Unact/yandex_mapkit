part of yandex_mapkit;

class SuggestSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_suggest_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;
  bool _isClosed = false;

  /// Has the current session been closed
  bool get isClosed => _isClosed;

  SuggestSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Resets current session
  ///
  /// After [SuggestSession.close] has been called, all subsequent calls will return a [SuggestSessionException]
  Future<void> reset() async {
    if (_isClosed) {
      throw SuggestSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('reset');
  }

  /// Closes current session
  ///
  /// After first call, all subsequent calls will return a [SuggestSessionException]
  Future<void> close() async {
    if (_isClosed) {
      throw SuggestSessionException._('Session is closed');
    }

    await _methodChannel.invokeMethod<void>('close');

    _isClosed = true;
  }
}

class SuggestSessionException extends SessionException {
  SuggestSessionException._(String message) : super._(message);
}

class SuggestSessionResult {
  final List<SuggestItem>? items;
  final String? error;

  SuggestSessionResult._(this.items, this.error);

  factory SuggestSessionResult.fromJson(Map<dynamic, dynamic> json) {
    return SuggestSessionResult._(
      json['items']?.map<SuggestItem>((dynamic item) => SuggestItem.fromJson(item)).toList(),
      json['error']
    );
  }
}

class SuggestResultWithSession {
  SuggestSession session;
  Future<SuggestSessionResult> result;

  SuggestResultWithSession._({
    required this.session,
    required this.result
  });
}
