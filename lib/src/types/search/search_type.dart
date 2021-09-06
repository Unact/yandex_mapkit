part of yandex_mapkit;

/// Not all possible types are implemented
/// More here:
/// - Android: https://yandex.ru/dev/maps/archive/doc/mapkit/3.0/concepts/android/mapkit/ref/com/yandex/mapkit/search/SearchType.html
/// - iOS: https://yandex.ru/dev/maps/archive/doc/mapkit/3.0/concepts/ios/mapkit/ref/YMKSearchOptions.html#property_detail__property_searchTypes
enum SearchType {
  none,
  geo,
  biz,
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
    }
  }
}
