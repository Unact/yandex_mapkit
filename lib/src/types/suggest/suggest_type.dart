part of yandex_mapkit;

/// All types availabled for suggestion.
enum SuggestType { unspecified, geo, biz, transit }

extension SuggestTypeExtension on SuggestType {
  int get value {
    switch (this) {
      case SuggestType.unspecified:
        return 0;
      case SuggestType.geo:
        return 1;
      case SuggestType.biz:
        return 1 << 1;
      case SuggestType.transit:
        return 1 << 2;
    }
  }
}
