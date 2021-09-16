part of yandex_mapkit;

class LocalizedValue extends Equatable {
  LocalizedValue(this.value, this.text);

  final double? value;
  final String text;

  @override
  List<Object?> get props => <Object?>[
    value,
    text,
  ];

  @override
  bool get stringify => true;
}
