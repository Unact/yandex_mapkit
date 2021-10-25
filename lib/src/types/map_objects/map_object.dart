part of yandex_mapkit;

abstract class MapObject {
  MapObject._(
    this.zIndex,
    this.isVisible,
    this.isDraggable,
    this.onTap,
  ) {
    id = '${(runtimeType)}_${_nextId++}';
  }

  static int _nextId = 0;

  late final String id;
  final onTap;
  final double zIndex;
  final bool isVisible;
  final bool isDraggable;

  Map<String, dynamic> toJson();
}
