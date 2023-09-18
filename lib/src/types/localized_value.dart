part of yandex_mapkit;

/// A value respecting the device locale.
class LocalizedValue extends Equatable {
  const LocalizedValue._(this.value, this.text);

  /// Value in SI units for distance, speed and duration.
  final double? value;

  /// Localized text. For example: "15 ft" or "42 km".
  final String text;

  factory LocalizedValue._fromJson(Map<dynamic, dynamic> json) {
    return LocalizedValue._(json['value'], json['text']);
  }

  @override
  List<Object?> get props => <Object?>[
        value,
        text,
      ];

  @override
  bool get stringify => true;
}
