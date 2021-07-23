part of yandex_mapkit;

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
