part of yandex_mapkit;

/// Found geo object item
class SearchItem extends Equatable {
  /// Objects name
  final String name;

  /// Objects geometry.
  final List<Geometry> geometry;

  /// Additional data for toponym objects.
  final SearchItemToponymMetadata? toponymMetadata;

  /// Extended information about company.
  final SearchItemBusinessMetadata? businessMetadata;

  const SearchItem._({
    required this.name,
    required this.geometry,
    this.toponymMetadata,
    this.businessMetadata,
  });

  factory SearchItem._fromJson(Map<dynamic, dynamic> json) {
    final toponymMetadata = json['toponymMetadata'] != null
        ? SearchItemToponymMetadata._fromJson(json['toponymMetadata'])
        : null;

    final businessMetadata = json['businessMetadata'] != null
        ? SearchItemBusinessMetadata._fromJson(json['businessMetadata'])
        : null;

    return SearchItem._(
      name: json['name'] ?? '',
      geometry:
          json['geometry'].map<Geometry>((i) => Geometry._fromJson(i)).toList(),
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
