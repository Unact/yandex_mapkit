part of yandex_mapkit;

class MapRect {

  final Offset min;
  final Offset max;

  MapRect({
    required this.min,
    required this.max,
  });

  Map<String, dynamic> toJson() {
    return {
      'min': {
        'dx': min.dx,
        'dy': min.dy,
      },
      'max': {
        'dx': max.dx,
        'dy': max.dy,
      }
    };
  }
}
