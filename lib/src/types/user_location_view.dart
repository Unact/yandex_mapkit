part of yandex_mapkit;

/// Interface used to specify the appearance of the user location icon elements.
class UserLocationView extends Equatable {
  const UserLocationView._(
      {required this.arrow, required this.pin, required this.accuracyCircle});

  /// GPS accuracy circle
  final CircleMapObject accuracyCircle;

  /// Location arrow placemark
  final PlacemarkMapObject arrow;

  /// Location pin placemark
  final PlacemarkMapObject pin;

  /// Returns a copy of [UserLocationView] with new appearance
  UserLocationView copyWith(
      {PlacemarkMapObject? arrow,
      PlacemarkMapObject? pin,
      CircleMapObject? accuracyCircle}) {
    return UserLocationView._(
        arrow: arrow ?? this.arrow,
        pin: pin ?? this.pin,
        accuracyCircle: accuracyCircle ?? this.accuracyCircle);
  }

  @override
  List<Object> get props => <Object>[arrow, pin, accuracyCircle];

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
