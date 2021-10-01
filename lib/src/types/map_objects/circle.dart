part of yandex_mapkit;

class Circle extends MapObject {
  Circle({
    required this.center,
    required this.radius,
    this.isGeodesic = false,
    this.style = const CircleStyle(),
    double zIndex = 0.0,
    TapCallback<Circle>? onTap
  }) : super._(zIndex, onTap);

  final Point center;
  final double radius;
  final bool isGeodesic;
  final CircleStyle style;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center': center.toJson(),
      'radius': radius,
      'isGeodesic': isGeodesic,
      'style': style.toJson(),
      'zIndex': zIndex
    };
  }
}

class CircleStyle extends Equatable {
  const CircleStyle({
    this.strokeColor = const Color(0xFF0066FF),
    this.strokeWidth = 5.0,
    this.fillColor = const Color(0xFF64B5F6),
  });

  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;

  @override
  List<Object> get props => <Object>[
    strokeColor,
    strokeWidth,
    fillColor,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'strokeColor': strokeColor.value,
      'strokeWidth': strokeWidth,
      'fillColor': fillColor.value,
    };
  }
}
