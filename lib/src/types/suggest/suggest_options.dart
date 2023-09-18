part of yandex_mapkit;

/// Options to fine-tune suggest request.
class SuggestOptions extends Equatable {
  /// What type of suggestions to look for
  /// If suggestType is empty, it means to use server-defined types
  final SuggestType suggestType;

  /// Enable word-by-word suggestion items.
  final bool suggestWords;

  /// The server uses the user position to calculate the distance from the user to suggest results.
  final Point? userPosition;

  const SuggestOptions({
    required this.suggestType,
    this.suggestWords = true,
    this.userPosition,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'suggestWords': suggestWords,
      'userPosition': userPosition?.toJson(),
      'suggestType': suggestType.index
    };
  }

  @override
  List<Object?> get props => <Object?>[suggestType, userPosition, suggestWords];

  @override
  bool get stringify => true;
}
