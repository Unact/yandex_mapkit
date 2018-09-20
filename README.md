# yandex_mapkit

A flutter plugin for displaying yandex maps on iOS and Android

__Warning__: The `YandexMapView` is not integrated in the widget tree, it is a native view on top of the flutter view.  
You won't be able to use snackbars, dialogs ...  
Scrolling is also not supported, since it relies on the widget tree  

__Disclaimer__: This project uses Yandex Mapkit which belongs to Yandex  
When using Mapkit refer to these [terms of use](https://tech.yandex.com/maps/doc/mapkit/3.x/concepts/conditions-docpage/)

## Getting Started

### Generate your API Key

1. Go to https://developer.tech.yandex.com
2. Create a `MapKit mobile SDK` key

### Usage

Prior to using the plugin, you must call `YandexMapkit.setup(apiKey: apiKey)`
Example:

```dart
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() async {
  await YandexMapkit.setup(apiKey: 'YOUR_API_KEY');
  runApp(MyApp());
}
```

You can use it as a standalone map, like so

```dart
YandexMap yandexMap = YandexMapkit().yandexMap;
yandexMap.resize(Rect.fromLTWH(200.0, 200.0, 100.0, 100.0));
yandexMap.show();
```

Or you can use a `YandexMapView` which does resizes itself to its parent size

```dart
Expanded(child: YandexMapView())
```

For usage examples refer to example app

### Features

- [X] iOS Support
- [X] Android Support
- [X] Add and remove Placemarks
- [X] Receive Placemark tap events
- [X] Moving around the map
- [X] Setting map bounds
