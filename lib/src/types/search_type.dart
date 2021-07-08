part of yandex_mapkit;

enum SearchType {
  // none,
  geo,
  biz,
  // transit,
  // collections,
  // direct,
  // goods,
  // pointsOfInterest,
  // massTransit
}

extension SearchTypeExtension on SearchType {

  int get value {
    switch (this) {
      // case SearchType.none:
      //   return 0;
      case SearchType.geo:
        return 1;
      case SearchType.biz:
        return 1 << 1;
      // case SearchType.transit:
      //   return 1 << 2;
      // case SearchType.collections:
      //   return 1 << 3;
      // case SearchType.direct:
      //   return 1 << 4;
      // case SearchType.goods:
      //   return 1 << 5;
      // case SearchType.pointsOfInterest:
      //   return 1 << 6;
      // case SearchType.massTransit:
      //   return 1 << 7;
    }
  }
}