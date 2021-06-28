part of yandex_mapkit;

class Circle extends Equatable {

  const Circle({
    required this.center,
    required this.radius,
    this.style = const CircleStyle(),
  });

  final Point   center;
  final double  radius;

  final CircleStyle style;

  @override
  List<Object> get props => <Object>[
    center,
    radius,
    style
  ];

  @override
  bool get stringify => true;
}
