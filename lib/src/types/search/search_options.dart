part of yandex_mapkit;

/// Options to fine-tune search request.
class SearchOptions extends Equatable {

  /// What type of searches to look for
  /// If searchType is empty, it means to use server-defined types
  final SearchType searchType;

  /// Adds the geometry to the server response.
  final bool geometry;

  /// Force disable correction of spelling mistakes.
  final bool disableSpellingCorrection;

  /// Maximum number of search results per page.
  final int? resultPageSize;

  /// The server uses the user position to calculate the distance from the user to suggest results.
  final Point? userPosition;

  /// String that sets an identifier for the request source.
  final String? origin;

  const SearchOptions({
    this.searchType = SearchType.none,
    this.geometry = false,
    this.disableSpellingCorrection = false,
    this.resultPageSize,
    this.userPosition,
    this.origin,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'searchType': searchType.index,
      'geometry': geometry,
      'disableSpellingCorrection': disableSpellingCorrection,
      'resultPageSize': resultPageSize,
      'userPosition': userPosition?.toJson(),
      'origin': origin
    };
  }

  @override
  List<Object?> get props => <Object?>[
    searchType,
    geometry,
    disableSpellingCorrection,
    resultPageSize,
    userPosition,
    origin
  ];

  @override
  bool get stringify => true;
}

/// Bitmask for requested search types.
/// Only none, geo, biz are currently implements
/// Other types are left for future compatability
enum SearchType {
  none,
  geo,
  biz,
  transit,
  collections,
  direct,
  goods,
  pointsOfInterest,
  massTransit
}

extension SearchTypeExtension on SearchType {
  int get value {
    switch (this) {
      case SearchType.none:
        return 0;
      case SearchType.geo:
        return 1;
      case SearchType.biz:
        return 1 << 1;
      case SearchType.transit:
        return 1 << 2;
      case SearchType.collections:
        return 1 << 3;
      case SearchType.direct:
        return 1 << 4;
      case SearchType.goods:
        return 1 << 5;
      case SearchType.pointsOfInterest:
        return 1 << 6;
      case SearchType.massTransit:
        return 1 << 7;
    }
  }
}
