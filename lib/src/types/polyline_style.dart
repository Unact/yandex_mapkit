part of yandex_mapkit;

class PolylineStyle extends Equatable {
  const PolylineStyle({
    this.strokeColor = kStrokeColor,
    this.strokeWidth = kStrokeWidth,
    this.outlineColor = kOutlineColor,
    this.outlineWidth = kOutlineWidth,
    this.isGeodesic = false,
    this.dashLength = kDashLength,
    this.dashOffset = kDashOffset,
    this.gapLength = kGapLength,
  });

  final Color strokeColor;
  final double strokeWidth;

  final Color outlineColor;
  final double outlineWidth;

  final bool isGeodesic;

  final double dashLength;
  final double dashOffset;
  final double gapLength;

  static const Color kStrokeColor = Color(0xFF0066FF);
  static const double kStrokeWidth = 5.0;
  static const Color kOutlineColor = Color(0x00000000);
  static const double kOutlineWidth = 0.0;
  static const double kDashLength = 0.0;
  static const double kDashOffset = 0.0;
  static const double kGapLength = 0.0;

  @override
  List<Object> get props => <Object>[
    strokeColor,
    strokeWidth,
    outlineColor,
    outlineWidth,
    isGeodesic,
    dashLength,
    dashOffset,
    gapLength,
  ];

  @override
  bool get stringify => true;
}
