part of '../../../yandex_mapkit.dart';

/// Defines a started suggest request
class SuggestSession {
  static const String _methodChannelName = 'yandex_mapkit/yandex_suggest_session_';
  final MethodChannel _methodChannel;

  /// Unique session identifier
  final int id;

  SuggestSession._({required this.id}) :
    _methodChannel = MethodChannel(_methodChannelName + id.toString());

  /// Resets current session
  Future<void> reset() async {
    await _methodChannel.invokeMethod<void>('reset');
  }

  /// Closes current session
  Future<void> close() async {
    await _methodChannel.invokeMethod<void>('close');
  }

  Future<SuggestSessionResult> _getSuggestions({
    required String text,
    required BoundingBox boundingBox,
    required SuggestOptions suggestOptions
  }) async {
    final params = <String, dynamic>{
      'text': text,
      'boundingBox': boundingBox.toJson(),
      'suggestOptions': suggestOptions.toJson(),
    };

    final result = await _methodChannel.invokeMethod('getSuggestions', params);

    return SuggestSessionResult._fromJson(result);
  }
}

/// Result of a suggest request
/// If any error has occured then [items] will be empty, otherwise [error] will be empty
class SuggestSessionResult {

  /// All found items
  final List<SuggestItem>? items;

  /// Error message
  final String? error;

  SuggestSessionResult._(this.items, this.error);

  factory SuggestSessionResult._fromJson(Map<dynamic, dynamic> json) {
    return SuggestSessionResult._(
      json['items']?.map<SuggestItem>((dynamic item) => SuggestItem._fromJson(item)).toList(),
      json['error']
    );
  }
}
