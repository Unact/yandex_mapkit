part of yandex_mapkit;

/// Defines the visible region.
class VisibleRegion extends Equatable {
  const VisibleRegion._(
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  );

  /// Top-left of the visible region.
  final Point topLeft;

  /// Top-right of the visible region.
  final Point topRight;

  /// Bottom-left of the visible region.
  final Point bottomLeft;

  /// Bottom-right of the visible region.
  final Point bottomRight;

  @override
  List<Object> get props => <Object>[
        topLeft,
        topRight,
        bottomLeft,
        bottomRight,
      ];

  @override
  bool get stringify => true;

  factory VisibleRegion._fromJson(Map<dynamic, dynamic> json) {
    return VisibleRegion._(
      Point._fromJson(json['topLeft']),
      Point._fromJson(json['topRight']),
      Point._fromJson(json['bottomLeft']),
      Point._fromJson(json['bottomRight']),
    );
  }
}
