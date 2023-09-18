part of yandex_mapkit;

/// Extended information about company.
class SearchItemBusinessMetadata extends Equatable {
  /// Company name.
  final String name;

  /// Short company name.
  final String? shortName;

  /// Human-readable address.
  final SearchAddress address;

  const SearchItemBusinessMetadata._({
    required this.name,
    required this.address,
    this.shortName,
  });

  factory SearchItemBusinessMetadata._fromJson(Map<dynamic, dynamic> json) {
    return SearchItemBusinessMetadata._(
        name: json['name'],
        shortName: json['shortName'],
        address: SearchAddress._fromJson(json['address']));
  }

  @override
  List<Object?> get props => <Object?>[
        name,
        address,
        shortName,
      ];

  @override
  bool get stringify => true;
}
