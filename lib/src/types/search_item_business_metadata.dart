part of yandex_mapkit;

class SearchItemBusinessMetadata extends Equatable {

  final String                          name;
  final String?                         shortName;
  final String                          formattedAddress;
  final Map<SearchComponentKind,String> addressComponents;

  const SearchItemBusinessMetadata({
    required this.name,
    required this.formattedAddress,
    required this.addressComponents,
    this.shortName,
  });

  factory SearchItemBusinessMetadata.fromJson(Map<dynamic, dynamic> json) {

    String? shortName;
    if (json.containsKey('shortName')) {
      shortName = json['shortName'];
    }

    var map = {};
    if (json['address']['addressComponents'] != null) {
      map = json['address']['addressComponents'] as Map;
    }

    Map<SearchComponentKind,String> addressMap;
    addressMap = map.map((key, value) => MapEntry(SearchComponentKind.values[key], value));

    return SearchItemBusinessMetadata(
      name:               json['name'],
      shortName:          shortName,
      formattedAddress:   json['address']['formattedAddress'],
      addressComponents:  addressMap,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    name,
    formattedAddress,
    addressComponents,
    shortName,
  ];

  @override
  bool get stringify => true;
}
