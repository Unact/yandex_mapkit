part of yandex_mapkit;

class SearchResponse extends Equatable {

  final int               found;
  final List<SearchItem>  items;

  const SearchResponse({
    required this.found,
    required this.items,
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
      found:  json['found'],
      items:  mappedItems ?? [],
    );
  }

  @override
  List<Object> get props => <Object>[
    found,
    items,
  ];

  @override
  bool get stringify => true;
}
