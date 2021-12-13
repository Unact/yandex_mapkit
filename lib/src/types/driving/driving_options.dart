part of yandex_mapkit;

/// Options to fine-tune driving request.
class DrivingOptions extends Equatable {

  /// Starting location azimuth.
  final double? initialAzimuth;

  /// The number of alternatives.
  final int? routesCount;

  /// Instructs the router to return routes that avoid tolls, when possible.
  final bool? avoidTolls;

  const DrivingOptions({
    this.initialAzimuth,
    this.routesCount,
    this.avoidTolls,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'initialAzimuth': initialAzimuth,
      'routesCount': routesCount,
      'avoidTolls': avoidTolls
    };
  }

  @override
  List<Object?> get props => <Object?>[
    initialAzimuth,
    routesCount,
    avoidTolls
  ];

  @override
  bool get stringify => true;
}
