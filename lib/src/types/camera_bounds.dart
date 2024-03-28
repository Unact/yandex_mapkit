part of '../../yandex_mapkit.dart';

/// Boundaries of the camera on map.
class CameraBounds extends Equatable {

  /// Minimum available zoom level considering zoom level
  final double minZoom;

  /// Maximum available zoom level considering zoom level
  final double maxZoom;

  /// Camera bounding box
  final BoundingBox? latLngBounds;

  const CameraBounds({
    this.minZoom = 2,
    this.maxZoom = 18,
    this.latLngBounds,
  });

  @override
  List<Object?> get props => <Object?>[
    minZoom,
    maxZoom,
    latLngBounds
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'minZoom': minZoom,
      'maxZoom': maxZoom,
      'latLngBounds': latLngBounds?.toJson()
    };
  }
}
