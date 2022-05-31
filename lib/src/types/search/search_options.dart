part of yandex_mapkit;

/// Options to fine-tune search request.
class SearchOptions extends Equatable {

  /// What type of searches to look for
  /// If searchType is empty, it means to use server-defined types
  final SearchType searchType;

  /// Snippets that will be requested
  final SearchSnippet searchSnippet;

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

  /// The landing page ID for Yandex.Direct.
  /// Used with [SearchType.direct].
  final String? directPageId;

  /// The context from an Apple-directed session.
  final String? appleCtx;

  /// The landing page ID for ads.
  final String? advertPageId;

  const SearchOptions({
    this.searchType = SearchType.none,
    this.searchSnippet = SearchSnippet.none,
    this.geometry = false,
    this.disableSpellingCorrection = false,
    this.resultPageSize,
    this.userPosition,
    this.origin,
    this.directPageId,
    this.appleCtx,
    this.advertPageId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'searchSnippet': searchSnippet.index,
      'searchType': searchType.index,
      'geometry': geometry,
      'disableSpellingCorrection': disableSpellingCorrection,
      'resultPageSize': resultPageSize,
      'userPosition': userPosition,
      'origin': origin,
      'directPageId': directPageId,
      'appleCtx': appleCtx,
      'advertPageId': advertPageId,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    searchType,
    geometry,
    disableSpellingCorrection,
    resultPageSize,
    userPosition,
    origin,
    directPageId,
    appleCtx,
    advertPageId,
  ];

  @override
  bool get stringify => true;
}

/// Requested snippets bitmask.
///
/// Snippets are additional pieces of information (possibly from
/// different services) which are not directly stored in object metadata
/// but may be requested separately based on client needs.
enum SearchSnippet {
  none,
  photos,
  businessRating1x,
  panoramas,
  massTransit,
  experimental,
  routeDistances,
  relatedPlaces,
  businessImages,
  references,
  fuel,
  exchange,
  nearbyStops,
  subtitle,
  routePoint,
  showtimes,
  relatedAdvertsOnMap,
  goods1x,
  discovery2x,
  relatedAdvertsOnCard,
  visualHints,
  encyclopedia
}

extension SearchSnippetExtension on SearchSnippet {
  int get value {
    switch (this) {
      case SearchSnippet.none:
        return 0;
      case SearchSnippet.photos:
        return 1;
      case SearchSnippet.businessRating1x:
        return 1 << 1;
      case SearchSnippet.panoramas:
        return 1 << 5;
      case SearchSnippet.massTransit:
        return 1 << 6;
      case SearchSnippet.experimental:
        return 1 << 7;
      case SearchSnippet.routeDistances:
        return 1 << 8;
      case SearchSnippet.relatedPlaces:
        return 1 << 9;
      case SearchSnippet.businessImages:
        return 1 << 10;
      case SearchSnippet.references:
        return 1 << 11;
      case SearchSnippet.fuel:
        return 1 << 12;
      case SearchSnippet.exchange:
        return 1 << 13;
      case SearchSnippet.nearbyStops:
        return 1 << 14;
      case SearchSnippet.subtitle:
        return 1 << 15;
      case SearchSnippet.routePoint:
        return 1 << 16;
      case SearchSnippet.showtimes:
        return 1 << 17;
      case SearchSnippet.relatedAdvertsOnMap:
        return 1 << 18;
      case SearchSnippet.goods1x:
        return 1 << 19;
      case SearchSnippet.discovery2x:
        return 1 << 20;
      case SearchSnippet.relatedAdvertsOnCard:
        return 1 << 21;
      case SearchSnippet.visualHints:
        return 1 << 22;
      case SearchSnippet.encyclopedia:
        return 1 << 23;
    }
  }
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
