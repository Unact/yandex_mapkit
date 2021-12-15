part of yandex_mapkit;

/// A single suggested item.
class SuggestItem extends Equatable {
  const SuggestItem._({
    required this.title,
    required this.subtitle,
    required this.displayText,
    required this.searchText,
    required this.type,
    required this.tags
  });

  factory SuggestItem._fromJson(Map<dynamic, dynamic> json) {
    return SuggestItem._(
      title: json['title'],
      subtitle: json['subtitle'],
      displayText: json['displayText'],
      searchText: json['searchText'],
      type: SuggestItemType.values[json['type']],
      tags: (json['tags'] as List<Object?>).cast<String>(),
    );
  }

  /// Short object name.
  final String title;

  /// If type is TOPONYM returns reversed toponym hierarchy.
  /// If type is BUSINESS returns business address.
  final String? subtitle;

  /// Text to display if searchText is too technical to display.
  final String displayText;

  /// Text to search for.
  final String searchText;

  /// Suggested object type.
  final SuggestItemType type;

  /// Additional free-form data for suggest item.
  ///
  /// If type is TOPONYM, returns toponym kind (house/street/locality/...).
  /// If type is BUSINESS, returns category class (drugstores/restaurants/...).
  final List<String> tags;

  @override
  List<Object?> get props => <Object?>[
    title,
    subtitle,
    searchText,
    type,
    tags
  ];

  @override
  bool get stringify => true;
}

enum SuggestItemType {
  unknown,
  toponym,
  business,
  transit
}
