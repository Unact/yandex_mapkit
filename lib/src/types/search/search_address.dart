part of yandex_mapkit;

/// Structured toponym address
class SearchAddress extends Equatable {
  const SearchAddress._({
    required this.formattedAddress,
    required this.addressComponents
  });

  /// Human-readable address.
  final String formattedAddress;

  /// Address component list.
  final Map<SearchComponentKind, String> addressComponents;

  factory SearchAddress._fromJson(Map<dynamic, dynamic> json) {
    final addressMap = (json['addressComponents'] as Map?)?.map<SearchComponentKind, String>(
      (key, value) => MapEntry(SearchComponentKind.values[key], value)
    ) ?? {};

    return SearchAddress._(
      formattedAddress: json['formattedAddress'],
      addressComponents: addressMap,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    formattedAddress,
    addressComponents
  ];

  @override
  bool get stringify => true;
}
