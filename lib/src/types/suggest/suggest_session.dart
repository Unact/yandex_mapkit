part of yandex_mapkit;

class SuggestSession {
  const SuggestSession(this.result, this.cancelSession);

  final Future<SuggestSessionResult> result;

  final CancelSuggestCallback cancelSession;
}

class SuggestSessionResult {
  final List<SuggestItem>? items;
  final String? error;

  SuggestSessionResult(this.items, this.error);

  factory SuggestSessionResult.fromJson(Map<String, dynamic> json) {
    final String? error = json['error'];
    final List<Map<String, dynamic>>? items = json['items'];
    return SuggestSessionResult(
      items?.map((it)=>SuggestItem.fromJson(it)).toList(),
      error
    );
  }
}
