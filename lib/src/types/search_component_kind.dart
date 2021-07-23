part of yandex_mapkit;

enum SearchComponentKind {

  /// 0 - Unknown component kind
  unknown,

  /// 1 - Country component, for example "Russian Federation".
  country,
  
  /// 2 - Region component, for example "Central Federative Region".
  region,

  ///3 - Province component, for example "Moscow Region".
  province,

  ///4 - Area component, for example "Primorskiy rayon".
  area,

  ///5 - Locality component, for example "Saint-Petersburg".
  locality,

  ///6 - District component, for example "Kirovskiy district".
  district,

  /// 7 - Street component, for example "Leo Tolstoy street".
  street,

  /// 8 - House component, for example "16", "42а", "д16ак2стр14".
  house,

  ///9 - Entrance component, for example "2", "main entrance".
  entrance,

  /// 10 - Line component, for example "Violet line"
  route,

  /// 11 - Generic station component, for example "Dolgoprudnaya".
  station,

  ///12 - Metro station component, for example "Chekhovskaya".
  metroStation,
  
  ///13 - Railway station component, for example "Chekhovskaya".
  railwayStation,

  ///14 - Vegetation component, for example "Bitsevskiy park".
  vegetation,

  /// 15 - Hydro component, for example "Moscow river", "Lokh-ness lake",
  hydro,
  
  ///16 - Airport component, for example "Sheremetyevo", "Charles-de-Golle
  airport,
  
  ///17 - Kind for other toponyms, for example cemeteries or some other landmarks, which can't be easily described by kinds.
  other
}
