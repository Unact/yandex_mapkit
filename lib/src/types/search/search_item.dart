part of yandex_mapkit;

class SearchItem extends Equatable {
  final String name;
  final List<Geometry> geometry;
  final SearchItemToponymMetadata? toponymMetadata;
  final SearchItemBusinessMetadata? businessMetadata;

  const SearchItem._({
    required this.name,
    required this.geometry,
    this.toponymMetadata,
    this.businessMetadata,
  });

  factory SearchItem._fromJson(Map<dynamic, dynamic> json) {
    var geometryItems = json['geometry'] as List;

    List<Geometry>? geometryList;
    geometryList = geometryItems.map((i) => Geometry._fromJson(i)).toList();

    SearchItemToponymMetadata? toponymMetadata;
    if (json.containsKey('toponymMetadata')) {
      toponymMetadata = SearchItemToponymMetadata._fromJson(json['toponymMetadata']);
    }

    SearchItemBusinessMetadata? businessMetadata;
    if (json.containsKey('businessMetadata')) {
      businessMetadata = SearchItemBusinessMetadata._fromJson(json['businessMetadata']);
    }

    return SearchItem._(
      name: json['name'] ?? '',
      geometry: geometryList,
      toponymMetadata: toponymMetadata,
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
