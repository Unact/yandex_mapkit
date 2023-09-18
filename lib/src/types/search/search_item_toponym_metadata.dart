part of yandex_mapkit;

/// Additional data for toponym objects.
class SearchItemToponymMetadata extends Equatable {
  /// Point where balloon for the toponym should be shown.
  ///
  /// Differs for direct and reverse search modes:
  /// Direct mode -- toponym center.
  /// Reverse mode -- toponym nearest point to the given coordinates.
  final Point balloonPoint;

  /// Human-readable address.
  final SearchAddress address;

  const SearchItemToponymMetadata._({
    required this.balloonPoint,
    required this.address,
  });

  factory SearchItemToponymMetadata._fromJson(Map<dynamic, dynamic> json) {
    return SearchItemToponymMetadata._(
      balloonPoint: Point._fromJson(json['balloonPoint']),
      address: SearchAddress._fromJson(json['address']),
    );
  }

  @override
  List<Object> get props => <Object>[
        balloonPoint,
        address,
      ];

  @override
  bool get stringify => true;
}
