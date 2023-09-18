part of yandex_mapkit;

/// Defines a bitmap image.
/// Used to provide Bitmap objects from different input sources.
class BitmapDescriptor extends Equatable {
  /// Serialized information about this bitmap image
  final Map<String, dynamic> _json;

  const BitmapDescriptor._(this._json);

  /// Creates a [BitmapDescriptor] from an asset image.
  factory BitmapDescriptor.fromAssetImage(String assetName) {
    return BitmapDescriptor._(
        {'type': 'fromAssetImage', 'assetName': assetName});
  }

  /// Creates a [BitmapDescriptor] using an array of bytes that must be encoded as PNG.
  factory BitmapDescriptor.fromBytes(Uint8List byteData) {
    return BitmapDescriptor._({'type': 'fromBytes', 'rawImageData': byteData});
  }

  Map<String, dynamic> toJson() => _json;

  @override
  List<Object> get props => <Object>[_json];

  @override
  bool get stringify => true;
}
