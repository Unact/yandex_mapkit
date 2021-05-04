part of yandex_mapkit;

class ScreenPoint extends Equatable{
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
}
