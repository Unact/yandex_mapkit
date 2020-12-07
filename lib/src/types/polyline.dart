part of yandex_mapkit;

class Polyline extends PolylineStyle with EquatableMixin {
  const Polyline({
    @required this.coordinates,
    Color strokeColor = PolylineStyle.kStrokeColor,
    double strokeWidth = PolylineStyle.kStrokeWidth,
    Color outlineColor = PolylineStyle.kOutlineColor,
    double outlineWidth = PolylineStyle.kOutlineWidth,
    bool isGeodesic = false,
    double dashLength = PolylineStyle.kDashLength,
    double dashOffset = PolylineStyle.kDashOffset,
    double gapLength = PolylineStyle.kGapLength,
  }) : super(
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          outlineColor: outlineColor,
          outlineWidth: outlineWidth,
          isGeodesic: isGeodesic,
          dashLength: dashLength,
          dashOffset: dashOffset,
          gapLength: gapLength,
        );

  final List<Point> coordinates;

  @override
  List<Object> get props => <Object>[
        coordinates,
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
