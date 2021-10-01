part of yandex_mapkit;

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
      tags: json['tags'],
    );
  }

  final String title;
  final String? subtitle;
  final String displayText;
  final String searchText;
  final SuggestItemType type;
  final List<dynamic> tags;

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
