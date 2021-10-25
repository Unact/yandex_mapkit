import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/data/dummy_image.dart' show rawImageData;
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

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

  late YandexMapController controller;

  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);

  final Placemark _placemark = Placemark(
    point: _point,
    onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
    style: PlacemarkStyle(
      icon: PlacemarkIcon.fromIconName(
        iconName: 'lib/assets/place.png',
      ),
      opacity: 0.7,
    ),
  );

  final Placemark _placemarkWithDynamicIcon = Placemark(
    point: const Point(latitude: 30.320045, longitude: 59.945933),
    onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
    style: PlacemarkStyle(
      icon: PlacemarkIcon.fromRawImageData(
        rawImageData: rawImageData,
      ),
      opacity: 0.95,
    ),
  );

  final Placemark _compositeIconPlacemark = Placemark(
      point: const Point(latitude: 34.820045, longitude: 45.945933),
      onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
      style: PlacemarkStyle(
        compositeIcon: {
          'user': PlacemarkIcon.fromIconName(
            iconName: 'lib/assets/user.png',
            style: PlacemarkIconStyle(
              anchor: Offset(0.5, 0.5),
            ),
          ),
          'arrow': PlacemarkIcon.fromIconName(
            iconName: 'lib/assets/arrow.png',
            style: PlacemarkIconStyle(
              anchor: Offset(0.5, 1.5),
            ),
          ),
        },
        opacity: 0.7,
      ),
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
                    ControlButton(
                      onPressed: () async {
                        await controller.addPlacemark(_placemark);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller.removePlacemark(_placemark);
                      },
                      title: 'Remove'
                    ),
                  ],
                ),
                const Text('Placemark with Binary Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        await controller.addPlacemark(_placemarkWithDynamicIcon);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller.removePlacemark(_placemarkWithDynamicIcon);
                      },
                      title: 'Remove'
                    ),
                  ],
                ),
                const Text('Placemark with Composite Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        await controller.addPlacemark(_compositeIconPlacemark);  // Add to the root collection (mapObjects)
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller.removePlacemark(_compositeIconPlacemark);
                      },
                      title: 'Remove'
                    ),
                  ],
                ),
              ]
            )
          )
        )
      ]
    );
  }
}
