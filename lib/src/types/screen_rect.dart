part of yandex_mapkit;

class ScreenRect extends Equatable {
  const ScreenRect({
    required this.topLeft,
    required this.bottomRight,
  });

  final ScreenPoint bottomRight;
  final ScreenPoint topLeft;

  @override
  List<Object> get props => <Object>[
    topLeft,
    bottomRight,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'topLeft': topLeft.toJson(),
      'bottomRight': bottomRight.toJson(),
    };
  }
}

class ScreenPoint extends Equatable {
  const ScreenPoint({
    required this.x,
    required this.y
  });

  final double x;
  final double y;

  @override
  List<Object> get props => <Object>[
    x,
    y
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory ScreenPoint._fromJson(Map<dynamic, dynamic> json) {
    return ScreenPoint(
      x: json['x'],
      y: json['y']
    );
  }
}
