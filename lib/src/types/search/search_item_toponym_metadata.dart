part of yandex_mapkit;

class SearchItemToponymMetadata extends Equatable {
  final Point balloonPoint;
  final String formattedAddress;
  final Map<SearchComponentKind, String> addressComponents;

  const SearchItemToponymMetadata._({
    required this.balloonPoint,
    required this.formattedAddress,
    required this.addressComponents,
  });

  factory SearchItemToponymMetadata._fromJson(Map<dynamic, dynamic> json) {
    var map = {};

    if (json['address']['addressComponents'] != null) {
      map = json['address']['addressComponents'] as Map;
    }

    Map<SearchComponentKind, String> addressMap;
    addressMap = map.map((key, value) => MapEntry(SearchComponentKind.values[key], value));

    return SearchItemToponymMetadata._(
      balloonPoint: Point._fromJson(json['balloonPoint']),
      formattedAddress: json['address']['formattedAddress'],
      addressComponents: addressMap,
    );
  }

  @override
  List<Object> get props => <Object>[
    balloonPoint,
    formattedAddress,
    addressComponents,
  ];

  @override
  bool get stringify => true;
}
