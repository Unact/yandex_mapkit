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

  factory VisibleRegion._fromJson(Map<dynamic, dynamic> json) {
    return VisibleRegion._(
      Point._fromJson(json['topLeft']),
      Point._fromJson(json['topRight']),
      Point._fromJson(json['bottomLeft']),
      Point._fromJson(json['bottomRight']),
    );
  }
}
