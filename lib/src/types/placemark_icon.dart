part of yandex_mapkit;

class PlacemarkIcon {

  final String?         iconName;
  final Uint8List?      rawImageData;
  final PlacemarkStyle? style;

  PlacemarkIcon({
    this.iconName,
    this.rawImageData,
    this.style,
  }) : assert((iconName != null || rawImageData != null), 'Either iconName or rawImageData must be provided');

  PlacemarkIcon.fromIconName({required String iconName, PlacemarkStyle? style}) :
        iconName = iconName, rawImageData = null, style = style;

  PlacemarkIcon.fromRawImageData({required Uint8List rawImageData, PlacemarkStyle? style}) :
        iconName = null, rawImageData = rawImageData, style = style;
}
