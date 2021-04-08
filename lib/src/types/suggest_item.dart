part of yandex_mapkit;

class SuggestItem extends Equatable {
  const SuggestItem({
    required this.title,
    required this.subtitle,
    required this.searchText,
    required this.type,
    required this.tags
  });

  factory SuggestItem.fromJson(Map<String, dynamic> json) {
    return SuggestItem(
      title: json['title'],
      subtitle: json['subtitle'],
      searchText: json['searchText'],
      type: json['type'],
      tags: json['tags'],
    );
  }

  final String title;
  final String subtitle;
  final String searchText;
  final String type;
  final List<dynamic> tags;

  @override
  List<Object> get props => <Object>[
    title,
    subtitle,
    searchText,
    type,
    tags
  ];

  @override
  bool get stringify => true;
}
