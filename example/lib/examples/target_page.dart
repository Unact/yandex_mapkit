import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';

class TargetPage extends MapPage {
  const TargetPage() : super('Target example');

  @override
  Widget build(BuildContext context) {
    return _TargetExample();
  }
}

class _TargetExample extends StatefulWidget {
  @override
  _TargetExampleState createState() => _TargetExampleState();
}

class _TargetExampleState extends State<_TargetExample> {
  YandexMapController controller;

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
                    RaisedButton(
                      onPressed: () async {
                        final Point currentTarget = await controller.enableCameraTracking(
                          Placemark(
                            point: const Point(latitude: 0, longitude: 0),
                            iconName: 'lib/assets/place.png',
                            opacity: 0.5,
                          ),
                          cameraPositionChanged
                        );
                        await addUserPlacemark(currentTarget);
                      },
                      child: const Text('Tracking')
                    ),
                    RaisedButton(
                      onPressed: () async {
                        final Point currentTarget = await controller.enableCameraTracking(
                          null,
                          cameraPositionChanged
                        );
                        await addUserPlacemark(currentTarget);
                      },
                      child: const Text('Tracking (without marker)')
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        await controller.disableCameraTracking();
                      },
                      child: const Text('Disable tracking')
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

  Future<void> cameraPositionChanged(dynamic arguments) async {
    final bool bFinal = arguments['final'];
    if (bFinal) {
      await addUserPlacemark(Point(
        latitude: arguments['latitude'],
        longitude: arguments['longitude']
      ));
    }
  }

  Future<void> addUserPlacemark(Point point) async {
    await controller.addPlacemark(Placemark(
      point: point,
      iconName: 'lib/assets/user.png',
      opacity: 0.9,
    ));
  }
}
