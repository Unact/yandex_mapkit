part of yandex_mapkit;

/// Map logo alignment.
class MapAlignment extends Equatable {
  const MapAlignment({
    required this.horizontal,
    required this.vertical,
  });

  /// Defines horizontal alignment.
  final HorizontalAlignment horizontal;

  /// Defines vertical alignment.
  final VerticalAlignment vertical;

  @override
  List<Object> get props => <Object>[
        horizontal,
        vertical,
      ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {'horizontal': horizontal.index, 'vertical': vertical.index};
  }
}

/// Horizontal logo alignment.
enum HorizontalAlignment { left, center, right }

/// Vertical logo alignment.
enum VerticalAlignment { top, bottom }
