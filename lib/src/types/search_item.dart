part of yandex_mapkit;

class SearchItem extends Equatable {

  final String                      name;
  final List<Geometry>              geometry;
  final SearchItemToponymMetadata?  toponymMetadata;
  final SearchItemBusinessMetadata? businessMetadata;

  const SearchItem({
    required this.name,
    required this.geometry,
    this.toponymMetadata,
    this.businessMetadata,
  });

  factory SearchItem.fromJson(Map<dynamic, dynamic> json) {

    var geometryItems = json['geometry'] as List;

    List<Geometry>? geometryList;
    geometryList = geometryItems.map((i) => Geometry.fromJson(i)).toList();

    SearchItemToponymMetadata? toponymMetadata;
    if (json.containsKey('toponymMetadata')) {
      toponymMetadata = SearchItemToponymMetadata.fromJson(json['toponymMetadata']);
    }

    SearchItemBusinessMetadata? businessMetadata;
    if (json.containsKey('businessMetadata')) {
      businessMetadata = SearchItemBusinessMetadata.fromJson(json['businessMetadata']);
    }

    return SearchItem(
      name:             json['name'] ?? '',
      geometry:         geometryList,
      toponymMetadata:  toponymMetadata,
      businessMetadata: businessMetadata,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    name,
    geometry,
    toponymMetadata,
    businessMetadata,
  ];

  @override
  bool get stringify => true;
}
