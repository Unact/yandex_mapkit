part of yandex_mapkit;

class MapSize extends Equatable {
  const MapSize({
    required this.width,
    required this.height
  });

  final int width;
  final int height;

  @override
  List<Object> get props => <Object>[
    width,
    height
  ];

  @override
  bool get stringify => true;
}
