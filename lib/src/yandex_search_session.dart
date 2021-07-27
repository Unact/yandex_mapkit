part of yandex_mapkit;

class SearchSession {

  static const String _channelName = 'yandex_mapkit/yandex_search';

  static const MethodChannel _channel = MethodChannel(_channelName);

  final int                   id;
  final SearchSessionCallback callback;
  final SearchErrorCallback?  errorCallback;

  SearchSession({required this.id, required this.callback, this.errorCallback}) {
    _channel.setMethodCallHandler(YandexSearch._handleMethodCall);
  }

  Future<void> cancelSearch() async {
    await _channel.invokeMethod<void>('cancelSearch', {'sessionId': id});
  }

  Future<void> retrySearch() async {
    await _channel.invokeMethod<void>('retrySearch', {'sessionId': id});
  }

  Future<void> fetchSearchNextPage() async {
    await _channel.invokeMethod<void>('fetchSearchNextPage', {'sessionId': id});
  }

  Future<void> closeSearchSession() async {
    await _channel.invokeMethod<void>('closeSearchSession', {'sessionId': id});
    YandexSearch._searchSessions.remove(this);
  }
}