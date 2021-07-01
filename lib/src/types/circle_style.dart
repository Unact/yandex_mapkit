part of yandex_mapkit;

class CircleStyle extends Equatable {

  const CircleStyle({
    this.strokeColor = kStrokeColor,
    this.strokeWidth = kStrokeWidth,
    this.fillColor   = kFillColor,
    this.isGeodesic = false,
  });

  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;

  final bool isGeodesic;

  static const Color kStrokeColor = Color(0xFF0066FF);
  static const double kStrokeWidth = 5.0;
  static const Color kFillColor = Color(0xFF64B5F6);

  @override
  List<Object> get props => <Object>[
    strokeColor,
    strokeWidth,
    fillColor,
    isGeodesic,
  ];

  @override
  bool get stringify => true;
}
