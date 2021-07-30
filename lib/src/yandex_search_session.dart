part of yandex_mapkit;

class SearchSession {

  static const String _methodChannelName = 'yandex_mapkit/yandex_search_session_';
  static const String _eventChannelName  = 'yandex_mapkit/yandex_search_session_events_';

  MethodChannel? _methodChannel;
  EventChannel?  _eventChannel;

  final int id;

  final _streamController = StreamController<SearchResponse>();
  Stream<SearchResponse> get results => _streamController.stream;

  SearchSession({required this.id}) {

    _methodChannel = MethodChannel(_methodChannelName + id.toString());
    _eventChannel  = EventChannel(_eventChannelName + id.toString());

    _eventChannel!.receiveBroadcastStream().listen(_onResponse, onError: _onError);
  }

  Future<void> cancelSearch() async {
    await _methodChannel!.invokeMethod<void>('cancelSearch');
  }

  Future<void> retrySearch() async {
    await _methodChannel!.invokeMethod<void>('retrySearch');
  }

  Future<void> fetchNextPage() async {
    await _methodChannel!.invokeMethod<void>('fetchNextPage');
  }

  Future<void> closeSession() async {

    await _streamController.sink.close();

    await _methodChannel!.invokeMethod<void>('closeSession');
  }

  void _onResponse(dynamic arguments) {

    final Map<dynamic, dynamic> response = arguments['response'];

    final respObj = SearchResponse.fromJson(response);

    _streamController.sink.add(respObj);
  }

  void _onError(dynamic arguments) {

    _streamController.sink.addError(arguments);
  }
}