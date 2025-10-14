part of '../../yandex_mapkit.dart';

/// Map logo padding.
class MapPadding extends Equatable {
  const MapPadding({
    required this.horizontal,
    required this.vertical,
  });

  /// The horizontal padding.
  final int horizontal;

  /// The vertical padding.
  final int vertical;

  @override
  List<Object> get props => <Object>[
    horizontal,
    vertical,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'horizontal': horizontal,
      'vertical': vertical,
    };
  }
}
