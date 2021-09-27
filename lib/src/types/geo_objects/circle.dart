part of yandex_mapkit;

class Circle extends Equatable {
  Circle({
    required this.center,
    required this.radius,
    this.isGeodesic = false,
    this.style = const CircleStyle(),
  }) : id = _nextIdVal;

  static int _nextId = 0;
  static String get _nextIdVal => '${(Circle)}_${_nextId++}';

  final String id;
  final Point center;
  final double radius;
  final bool isGeodesic;
  final CircleStyle style;

  @override
  List<Object> get props => <Object>[
    center,
    radius,
    isGeodesic,
    style,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center': center.toJson(),
      'radius': radius,
      'isGeodesic': isGeodesic,
      'style': style.toJson(),
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
