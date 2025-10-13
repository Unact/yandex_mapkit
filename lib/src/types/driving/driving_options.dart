part of '../../../yandex_mapkit.dart';

/// Options to fine-tune driving request.
class DrivingOptions extends Equatable {

  /// Starting location azimuth.
  final double? initialAzimuth;

  /// The number of alternatives.
  final int? routesCount;

  /// Desired departure time in UTC for a time-dependent route request.
  /// This option cannot be used with [arrivalTime].
  final DateTime? departureTime;

  /// The annotation language.
  final AnnotationLanguage? annotationLanguage;

  /// Instructs the router to return routes that avoid tolls, when possible.
  final DrivingAvoidanceFlags? avoidanceFlags;

  const DrivingOptions({
    this.initialAzimuth,
    this.routesCount,
    this.departureTime,
    this.annotationLanguage,
    this.avoidanceFlags
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'initialAzimuth': initialAzimuth,
      'routesCount': routesCount,
      'departureTime': departureTime,
      'annotationLanguage': annotationLanguage?.index,
      'avoidanceFlags': avoidanceFlags?.toJson()
    };
  }

  @override
  List<Object?> get props => <Object?>[
    initialAzimuth,
    routesCount,
    annotationLanguage,
    departureTime?.millisecondsSinceEpoch,
    avoidanceFlags
  ];

  @override
  bool get stringify => true;
}
