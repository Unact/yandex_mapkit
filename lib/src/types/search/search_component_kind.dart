part of yandex_mapkit;

enum SearchComponentKind {
  /// Unknown component kind
  unknown,

  /// Country component, for example "Russian Federation".
  country,

  /// Region component, for example "Central Federative Region".
  region,

  /// Province component, for example "Moscow Region".
  province,

  /// Area component, for example "Primorskiy rayon".
  area,

  /// Locality component, for example "Saint-Petersburg".
  locality,

  /// District component, for example "Kirovskiy district".
  district,

  /// Street component, for example "Leo Tolstoy street".
  street,

  /// House component, for example "16", "42а", "д16ак2стр14".
  house,

  /// Entrance component, for example "2", "main entrance".
  entrance,

  /// Line component, for example "Violet line"
  route,

  /// Generic station component, for example "Dolgoprudnaya".
  station,

  /// Metro station component, for example "Chekhovskaya".
  metroStation,

  /// Railway station component, for example "Chekhovskaya".
  railwayStation,

  /// Vegetation component, for example "Bitsevskiy park".
  vegetation,

  /// Hydro component, for example "Moscow river", "Lokh-ness lake",
  hydro,

  /// Airport component, for example "Sheremetyevo", "Charles-de-Golle
  airport,

  /// Kind for other toponyms, for example cemeteries or some other landmarks,
  /// which can't be easily described by kinds.
  other
}
