part of '../../yandex_mapkit.dart';

/// Options to fine-tune pedestrian request.
class FitnessOptions extends Equatable {

  /// Instruct router to avoid steep routes.
  final bool avoidSteep;

  /// Instruct router to avoid stairs.
  final bool avoidStairs;

  const FitnessOptions({
    required this.avoidSteep,
    required this.avoidStairs
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'avoidSteep': avoidSteep,
      'avoidStairs': avoidStairs
    };
  }

  @override
  List<Object?> get props => <Object?>[
    avoidSteep,
    avoidStairs
  ];

  @override
  bool get stringify => true;
}
