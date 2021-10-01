part of yandex_mapkit;

class MapSize extends Equatable {
  const MapSize._(this.width, this.height);

  final int width;
  final int height;

  @override
  List<Object> get props => <Object>[
    width,
    height
  ];

  @override
  bool get stringify => true;

  factory MapSize._fromJson(Map<dynamic, dynamic> json) {
    return MapSize._(json['width'], json['height']);
  }
}
