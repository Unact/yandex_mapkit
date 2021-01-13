part of yandex_mapkit;

class PolygonStyle extends Equatable {
  const PolygonStyle({
    this.strokeWidth = kStrokeWidth,
    this.strokeColor = kStrokeColor,
    this.fillColor = kFillColor,
    this.isGeodesic = kIsGeodesic,
  });

  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  final bool isGeodesic;

  static const Color kStrokeColor = Color(0x00000000);
  static const Color kFillColor = Color(0xFF0066FF);
  static const double kStrokeWidth = 1;
  static const bool kIsGeodesic = false;

  @override
  List<Object> get props => <Object>[
    fillColor,
    strokeColor,
    strokeWidth,
    isGeodesic
  ];

  @override
  bool get stringify => true;
}
