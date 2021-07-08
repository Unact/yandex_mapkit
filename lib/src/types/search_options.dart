part of yandex_mapkit;

class SearchOptions {

  final SearchType  searchType;
  final bool        geometry;
  final bool        suggestWords;
  final bool        disableSpellingCorrection;
  final int?        resultPageSize;
  final Point?      userPosition;

  SearchOptions({
    required this.searchType,
    this.geometry = false,
    this.suggestWords = true,
    this.disableSpellingCorrection = false,
    this.resultPageSize,
    this.userPosition,
  });
}
