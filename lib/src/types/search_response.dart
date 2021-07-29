part of yandex_mapkit;

class SearchResponse extends Equatable {

  final int?                found;
  final List<SearchItem>?   items;
  final int?                page;
  final bool?               hasNextPage;
  final String?             error;

  const SearchResponse({
    this.found,
    this.items,
    this.page,
    this.hasNextPage,
    this.error,
  }) : assert((error != null || (found != null && items != null && page != null && hasNextPage != null)), 'Either error or result attributes must be provided');;

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
      error:        json['error'],
    );
  }

  @override
  List<Object?> get props => <Object?>[
    found,
    items,
    page,
    hasNextPage,
    error,
  ];

  @override
  bool get stringify => true;
}
