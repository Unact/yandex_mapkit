part of yandex_mapkit;

/// Options to fine-tune driving request.
class DrivingOptions extends Equatable {
  /// Starting location azimuth.
  final double? initialAzimuth;

  /// The number of alternatives.
  final int? routesCount;

  /// Instructs the router to return routes that avoid tolls, when possible.
  final bool? avoidTolls;

  /// Instructs the router to return routes that avoid unpaved roads when possible.
  final bool? avoidUnpaved;

  /// Instructs the router to return routes that avoid roads in poor conditions when possible.
  final bool? avoidPoorConditions;

  const DrivingOptions(
      {this.initialAzimuth,
      this.routesCount,
      this.avoidTolls,
      this.avoidUnpaved,
      this.avoidPoorConditions});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'initialAzimuth': initialAzimuth,
      'routesCount': routesCount,
      'avoidTolls': avoidTolls,
      'avoidUnpaved': avoidUnpaved,
      'avoidPoorConditions': avoidPoorConditions
    };
  }

  @override
  List<Object?> get props => <Object?>[
        initialAzimuth,
        routesCount,
        avoidTolls,
        avoidUnpaved,
        avoidPoorConditions
      ];

  @override
  bool get stringify => true;
}
