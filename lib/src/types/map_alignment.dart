part of yandex_mapkit;

class MapAlignment extends Equatable {
  const MapAlignment({
    required this.horizontal,
    required this.vertical,
  });

  final HorizontalAlignment horizontal;
  final VerticalAlignment vertical;

  @override
  List<Object> get props => <Object>[
    horizontal,
    vertical,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'horizontal': horizontal.index,
      'vertical': vertical.index
    };
  }
}

enum HorizontalAlignment {
  left,
  center,
  right
}

enum VerticalAlignment {
  top,
  bottom
}
