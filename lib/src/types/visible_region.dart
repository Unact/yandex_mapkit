part of yandex_mapkit;

class VisibleRegion extends Equatable {
  const VisibleRegion._(
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  );

  final Point topLeft;
  final Point topRight;
  final Point bottomLeft;
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

  factory VisibleRegion.fromJson(Map<dynamic, dynamic> json) {
    return VisibleRegion._(
      Point.fromJson(json['topLeft']),
      Point.fromJson(json['topRight']),
      Point.fromJson(json['bottomLeft']),
      Point.fromJson(json['bottomRight']),
    );
  }
}
