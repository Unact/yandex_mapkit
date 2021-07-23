part of yandex_mapkit;

class SearchOptions {

  final SearchType  searchType;
  final bool        geometry;
  final bool        suggestWords;
  final bool        disableSpellingCorrection;
  final int?        resultPageSize;
  final Point?      userPosition;
  final String?     origin;
  final String?     directPageId;
  final String?     appleCtx;
  final String?     advertPageId;

  SearchOptions({
    required this.searchType,
    this.geometry = false,
    this.suggestWords = true,
    this.disableSpellingCorrection = false,
    this.resultPageSize,
    this.userPosition,
    this.origin,
    this.directPageId,
    this.appleCtx,
    this.advertPageId,
  });

  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{
      'searchType':                 searchType.index,
      'geometry':                   geometry,
      'suggestWords':               suggestWords,
      'disableSpellingCorrection':  disableSpellingCorrection,
    };

    if (resultPageSize != null) {
      json['resultPageSize'] = resultPageSize!;
    }

    if (userPosition != null) {
      json['userPosition'] = userPosition!;
    }

    if (origin != null) {
      json['origin'] = origin!;
    }

    if (directPageId != null) {
      json['directPageId'] = directPageId!;
    }

    if (appleCtx != null) {
      json['appleCtx'] = appleCtx!;
    }

    if (advertPageId != null) {
      json['advertPageId'] = advertPageId!;
    }

    return json;
  }
}
