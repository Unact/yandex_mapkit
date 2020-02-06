import 'dart:async';

import 'package:flutter/services.dart';

import 'point.dart';
import 'suggest_item.dart';

typedef MultiUseCallback = void Function(dynamic msg);
typedef CancelListening = void Function();

class YandexSearch {
  factory YandexSearch() => _instance;

  YandexSearch.private(MethodChannel channel) : _channel = channel;

  final MethodChannel _channel;

  static final YandexSearch _instance = YandexSearch.private(const MethodChannel('yandex_mapkit/yandex_search'));

  int _nextCallbackId = 0;
  final Map<int, MultiUseCallback> _suggestSessionsById = Map<int, MultiUseCallback>();

  Future<CancelListening> getSuggestions(
    String address,
    Point southWestPoint,
    Point northEastPoint,
    String suggestType,
    bool suggestWords,
    MultiUseCallback callback
  ) async {
    _channel.setMethodCallHandler(_handleMethodCall);

    final int listenerId = _nextCallbackId++;
    _suggestSessionsById[listenerId] = callback;

    await _channel.invokeMethod<void>(
      'getSuggestions',
      <String, dynamic>{
        'formattedAddress': address,
        'southWestLatitude': southWestPoint.latitude,
        'southWestLongitude': southWestPoint.longitude,
        'northEastLatitude': northEastPoint.latitude,
        'northEastLongitude': northEastPoint.longitude,
        'suggestType': suggestType,
        'suggestWords': suggestWords,
        'listenerId': listenerId
      }
    );

    return () => _cancelSuggestSession(listenerId);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSuggestListenerResponse':
        _onSuggestListenerResponse(call.arguments);
        break;
      case 'onSuggestListenerError':
        _onSuggestListenerError(call.arguments);
        break;
      case 'onSuggestListenerRemove':
        _onSuggestListenerRemove(call.arguments);
        break;
      default:
        throw MissingPluginException();
    }
  }

  void _onSuggestListenerRemove(dynamic arguments) {
    _cancelSuggestSession(arguments['listenerId']);
  }

  Future<void> _cancelSuggestSession(int listenerId) async {
    if (_suggestSessionsById.containsKey(listenerId)) {
      await _channel.invokeMethod<void>(
        'cancelSuggestSession',
        <String, dynamic>{
          'listenerId': listenerId
        }
      );
      _suggestSessionsById.remove(listenerId);
    }
  }

  void _onSuggestListenerResponse(dynamic arguments) {
    final List<dynamic> suggests = arguments['response'];
    final List<SuggestItem> suggestItems = suggests.map((dynamic sug) {
      return SuggestItem(
        searchText: sug['searchText'],
        title: sug['title'],
        subtitle: sug['subtitle'],
        tags: sug['tags'],
        type: sug['type'],
      );
    }).toList();
    final int listenerId = arguments['listenerId'];
    _suggestSessionsById[listenerId](suggestItems);
    _cancelSuggestSession(listenerId);
  }

  void _onSuggestListenerError(dynamic arguments) {
    _cancelSuggestSession(arguments['listenerId']);
  }
}