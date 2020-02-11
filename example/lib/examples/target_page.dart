import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/page.dart';

class TargetPage extends Page {
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
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);

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
              controller.onCameraPositionChanged = cameraPositionChanged;
            },
          )
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text('Camera marker:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        await controller.setCameraTargetPlacemark(
                          Placemark(
                            point: _point,
                            opacity: 0.7,
                            iconName: 'lib/assets/place.png'
                          )
                        );
                      },
                      child: const Text('Enable target')
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await controller.setCameraTargetPlacemark(null);
                      },
                      child: const Text('Disable target')
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

  void cameraPositionChanged(dynamic arguments) {
    final bool bFinal = arguments['final'];
    if (bFinal) {
      controller.addPlacemark(Placemark(
        point: Point(latitude: arguments['latitude'], longitude: arguments['longitude']),
        opacity: 0.7,
        iconName: 'lib/assets/user.png'
      ));
    }
  }
}
