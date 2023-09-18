part of yandex_mapkit;

/// A rectangle on the device screen.
class ScreenRect extends Equatable {
  const ScreenRect({
    required this.topLeft,
    required this.bottomRight,
  });

  /// The position of the bottom right corner of the rectangle.
  final ScreenPoint bottomRight;

  /// The position of the top left corner of the rectangle.
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

/// A point on the device screen.
class ScreenPoint extends Equatable {
  const ScreenPoint({required this.x, required this.y});

  /// The horizontal position of the point in pixels from the top screen border.
  final double x;

  /// The vertical position of the point in pixels from the top screen border.
  final double y;

  @override
  List<Object> get props => <Object>[x, y];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory ScreenPoint._fromJson(Map<dynamic, dynamic> json) {
    return ScreenPoint(x: json['x'], y: json['y']);
  }
}
