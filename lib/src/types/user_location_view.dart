part of yandex_mapkit;

/// Interface used to specify the appearance of the user location icon elements.
class UserLocationView extends Equatable {
  const UserLocationView._({
    required this.arrow,
    required this.pin,
    required this.accuracyCircle
  });

  /// GPS accuracy circle
  final Circle accuracyCircle;

  /// Location arrow placemark
  final Placemark arrow;

  /// Location pin placemark
  final Placemark pin;

  /// Returns a copy of [UserLocationView] with new appearance
  UserLocationView copyWith({
    Placemark? arrow,
    Placemark? pin,
    Circle? accuracyCircle
  }) {
    return UserLocationView._(
      arrow: arrow ?? this.arrow,
      pin: pin ?? this.pin,
      accuracyCircle: accuracyCircle ?? this.accuracyCircle
    );
  }

  @override
  List<Object> get props => <Object>[
    arrow,
    pin,
    accuracyCircle
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'arrow': arrow.toJson(),
      'pin': pin.toJson(),
      'accuracyCircle': accuracyCircle.toJson()
    };
  }

}
