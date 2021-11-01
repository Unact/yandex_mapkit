part of yandex_mapkit;

class Rect {

  final Offset min;
  final Offset max;

  Rect({
    required this.min,
    required this.max,
  });

  Map<String, dynamic> toJson() {

    var json = {
      'min': {
        'x': min.dx,
        'y': min.dy,
      },
      'max': {
        'x': max.dx,
        'y': max.dy,
      }
    };

    return json;
  }
}
