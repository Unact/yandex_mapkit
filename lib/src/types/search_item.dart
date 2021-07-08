part of yandex_mapkit;

class SearchItem extends Equatable {

  final String                    name;
  final SearchItemToponymMetadata toponymMetadata;

  const SearchItem({
    required this.name,
    required this.toponymMetadata,
  });

  factory SearchItem.fromJson(Map<dynamic, dynamic> json) {

    return SearchItem(
      name:             json['name'] ?? "",
      toponymMetadata:  SearchItemToponymMetadata.fromJson(json['toponymMetadata']),
    );
  }

  @override
  List<Object> get props => <Object>[
    name,
    toponymMetadata,
  ];

  @override
  bool get stringify => true;
}
