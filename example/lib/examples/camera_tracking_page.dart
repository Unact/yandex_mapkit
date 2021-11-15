import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class CameraTrackingPage extends MapPage {
  const CameraTrackingPage() : super('Camera tracking example');

  @override
  Widget build(BuildContext context) {
    return _CameraTrackingExample();
  }
}

class _CameraTrackingExample extends StatefulWidget {
  @override
  _CameraTrackingExampleState createState() => _CameraTrackingExampleState();
}

class _CameraTrackingExampleState extends State<_CameraTrackingExample> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  int _placemarkIdCounter = 1;
  final MapObjectId cameraPlacemarkId = MapObjectId('camera_placemark');

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        mapObjects.add(
                          Placemark(
                            mapId: cameraPlacemarkId,
                            point: (await controller.getCameraPosition()).target,
                            style: PlacemarkStyle(
                              icon: PlacemarkIcon.fromIconName(
                                iconName: 'lib/assets/user.png',
                              ),
                              opacity: 0.9,
                            ),
                          )
                        );

                        await controller.updateMapObjects(mapObjects);
                        await controller.enableCameraTracking(onCameraPositionChange: cameraPositionChanged);
                      },
                      title: 'Enable tracking'
                    ),
                    ControlButton(
                      onPressed: () async {
                        mapObjects.clear();

                        await controller.disableCameraTracking();
                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Disable tracking'
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

  Future<void> cameraPositionChanged(CameraPosition cameraPosition, bool finished) async {
    final cameraPlacemark = mapObjects.firstWhere((el) => el.mapId == cameraPlacemarkId) as Placemark;
    mapObjects[mapObjects.indexOf(cameraPlacemark)] = cameraPlacemark.copyWith(point: cameraPosition.target);

    if (finished) {
      final placemark = Placemark(
        mapId: MapObjectId('placemark_${_placemarkIdCounter++}'),
        point: cameraPosition.target,
        style: PlacemarkStyle(
          icon: PlacemarkIcon.fromIconName(
            iconName: 'lib/assets/place.png',
          ),
          opacity: 0.9,
        ),
      );

      mapObjects.add(placemark);
    }

    await controller.updateMapObjects(mapObjects);
  }
}
