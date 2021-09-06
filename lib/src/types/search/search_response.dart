part of yandex_mapkit;

class SearchResponse extends Equatable {

  final int               found;
  final List<SearchItem>  items;
  final int               page;

  const SearchResponse({
    required this.found,
    required this.items,
    required this.page,
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
      found: json['found'],
      items: mappedItems ?? [],
      page:  json['page'],
    );
  }

  @override
  List<Object?> get props => <Object?>[
    found,
    items,
    page,
  ];

  @override
  bool get stringify => true;
}

class SearchResponseOrError {

  SearchResponse? response;
  String?         error;

  SearchResponseOrError({
    this.response,
    this.error
  }) : assert(response != null || error != null);
}

class SearchResponseWithSession {

  SearchSession                 session;
  Future<SearchResponseOrError> responseOrError;

  SearchResponseWithSession({
    required this.session,
    required this.responseOrError
  });
}
