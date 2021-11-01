part of yandex_mapkit;

abstract class MapObject {
  MapObject._(
    this.zIndex,
    this.onTap,
  ) {
    id = '${(runtimeType)}_${_nextId++}';
  }

  static int _nextId = 0;

  late final String id;
  final onTap;
  final double zIndex;

  Map<String, dynamic> toJson();
}
