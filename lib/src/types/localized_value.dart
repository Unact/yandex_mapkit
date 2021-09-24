part of yandex_mapkit;

class LocalizedValue extends Equatable {
  const LocalizedValue._(this.value, this.text);

  final double? value;
  final String text;

  factory LocalizedValue.fromJson(Map<dynamic, dynamic> json) {
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
