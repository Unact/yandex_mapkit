import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';
import 'package:yandex_mapkit_example/examples/data/dummy_image.dart' show rawImageData;

class PlacemarkPage extends MapPage {
  const PlacemarkPage() : super('Placemark example');

  @override
  Widget build(BuildContext context) {
    return _PlacemarkExample();
  }
}

class _PlacemarkExample extends StatefulWidget {
  @override
  _PlacemarkExampleState createState() => _PlacemarkExampleState();
}

class _PlacemarkExampleState extends State<_PlacemarkExample> {
  YandexMapController controller;
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  final Placemark _placemark = Placemark(
    point: _point,
    opacity: 0.7,
    iconName: 'lib/assets/place.png',
    onTap: (Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
  );

  final Placemark _placemarkWithDynamicIcon = Placemark(
    point: const Point(latitude: 30.320045, longitude: 59.945933),
    opacity: 0.95,
    rawImageData: rawImageData,
    onTap: (Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: YandexMap(
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;
            },
          )
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text('Placemark with Assets Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        await controller.addPlacemark(_placemark);
                      },
                      child: const Text('Add')
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await controller.removePlacemark(_placemark);
                      },
                      child: const Text('Remove')
                    ),
                  ],
                ),
                const Text('Placemark with Binary Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        await controller.addPlacemark(_placemarkWithDynamicIcon);
                      },
                      child: const Text('Add')
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await controller.removePlacemark(_placemarkWithDynamicIcon);
                      },
                      child: const Text('Remove')
                    ),
                  ],
                )
              ]
            )
          )
        )
      ]
    );
  }
}
