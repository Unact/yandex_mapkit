part of yandex_mapkit;

class SearchResponse extends Equatable {

  final int                found;
  final List<SearchItem>   items;
  final int                page;
  final bool               hasNextPage;

  const SearchResponse({
    required this.found,
    required this.items,
    required this.page,
    required this.hasNextPage,
  });

  factory SearchResponse.fromJson(Map<dynamic, dynamic> json) {

    List? items;
    if (json['items'] != null) {
      items = json['items'] as List?;
    }

    List<SearchItem>? mappedItems;
    if (items != null) {
      mappedItems = items.map((i) => SearchItem.fromJson(i)).toList();
    }

    return SearchResponse(
      found:        json['found'],
      items:        mappedItems ?? [],
      page:         json['page'],
      hasNextPage:  json['hasNextPage'],
    );
  }

  @override
  List<Object?> get props => <Object?>[
    found,
    items,
    page,
    hasNextPage,
  ];

  @override
  bool get stringify => true;
}
