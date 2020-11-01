import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';

class RotatePage extends MapPage {
  const RotatePage() : super('Rotate example');

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

  YandexMapController controller;
  bool rotationBlocked = false;

  void _addPlacemarkPinned() {
    const Point point = Point(latitude: 59.945933, longitude: 30.320045);
    final Placemark placemark = Placemark(
      point: point,
      opacity: 0.7,
      iconName: 'lib/assets/place.png',
      onTap: (Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
      rotationType: 'rotate',
    );
    controller.addPlacemark(placemark);
  }

  void _blockCameraRotate() {
    setState(() => rotationBlocked = !rotationBlocked);
    controller.toggleMapRotation(enabled: !rotationBlocked);
  }

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
                RaisedButton(
                  child: const Text('Add placemark with pinned direction'),
                  onPressed: _addPlacemarkPinned,
                ),
                RaisedButton(
                  child: Text('Toggle camera rotation: ${rotationBlocked ? 'ON' : 'OFF'}'),
                  onPressed: _blockCameraRotate,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

}


