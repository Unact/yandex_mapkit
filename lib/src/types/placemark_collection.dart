part of yandex_mapkit;

class PlacemarkCollectionItem {
  PlacemarkCollectionItem({
    @required this.point,
    dynamic id,
    this.onTap,
  }) : _id = id;

  final Point point;

  dynamic get id => _id ?? hashCode;
  final dynamic _id;
  final ArgumentCallback<dynamic> onTap;
}

class PlacemarkCollection {
  PlacemarkCollection({
    @required this.items,
    this.style = const PlacemarkStyle(),
  });

  final List<PlacemarkCollectionItem> items;
  final PlacemarkStyle style;
}