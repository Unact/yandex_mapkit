import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class RotationPage extends MapPage {
  const RotationPage() : super('Rotation example');

  @override
  Widget build(BuildContext context) {
    return _RotateExample();
  }
}

class _RotateExample extends StatefulWidget {
  @override
  _RotateExampleState createState() => _RotateExampleState();
}

class _RotateExampleState extends State<_RotateExample> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  bool rotationBlocked = false;
  final PlacemarkId rotatedPlacemarkId = PlacemarkId('pinned_rotated_placemark');
  final PlacemarkId normalPlacemarkId = PlacemarkId('normal_placemark');

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

              mapObjects.add(Placemark(
                placemarkId: normalPlacemarkId,
                point: Point(latitude: 59.945933, longitude: 30.320045),
                onTap: (Placemark self, Point point) => print('Tapped me at $point'),
                style: PlacemarkStyle(
                  opacity: 0.7,
                  iconName: 'lib/assets/place.png',
                )
              ));
              mapObjects.add(Placemark(
                placemarkId: rotatedPlacemarkId,
                point: Point(latitude: 40.945933, longitude: 32.320045),
                onTap: (Placemark self, Point point) => print('Tapped me at $point'),
                style: PlacemarkStyle(
                  opacity: 0.7,
                  iconName: 'lib/assets/arrow.png',
                  rotationType: RotationType.rotate,
                  direction: 90,
                ),
              ));
              await controller.updateMapObjects(mapObjects);
            },
          )
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ControlButton(
                  onPressed: () async {
                    final placemark = mapObjects.firstWhere((el) => el.mapId == rotatedPlacemarkId) as Placemark;
                    mapObjects[mapObjects.indexOf(placemark)] = placemark.copyWith(style:
                      PlacemarkStyle(
                        opacity: 0.7,
                        iconName: 'lib/assets/arrow.png',
                        rotationType: RotationType.rotate,
                        direction: placemark.style.direction + 5.0
                      ),
                    );

                    await controller.updateMapObjects(mapObjects);
                  },
                  title: 'Update placemark rotation direction'
                ),
                ControlButton(
                  onPressed: () async {
                    await controller.toggleMapRotation(enabled: !rotationBlocked);

                    setState(() {
                      rotationBlocked = !rotationBlocked;
                    });
                  },
                  title: 'Toggle camera rotation: ${rotationBlocked ? 'ON' : 'OFF'}'
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
