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

  YandexMapController? controller;
  bool rotationBlocked = false;

  void _addPlacemarkPinnedRotated() {
    const point = Point(latitude: 59.945933, longitude: 30.320045);
    final placemark = Placemark(
      point: point,
      onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
      style: const PlacemarkStyle(
        opacity: 0.7,
        iconName: 'lib/assets/place.png',
        rotationType: RotationType.rotate,
        direction: 90,
      ),
    );
    controller!.addPlacemark(placemark);
  }

  void _addPlacemarkPinned() {
    const point = Point(latitude: 59.945933, longitude: 30.320045);
    final placemark = Placemark(
      point: point,
      onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
      style: const PlacemarkStyle(
        opacity: 0.7,
        iconName: 'lib/assets/place.png',
      )
    );
    controller!.addPlacemark(placemark);
  }

  void _blockCameraRotate() {
    setState(() => rotationBlocked = !rotationBlocked);
    controller!.toggleMapRotation(enabled: !rotationBlocked);
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
                ControlButton(
                  onPressed: _addPlacemarkPinned,
                  title: 'Add placemark with pinned direction'
                ),
                ControlButton(
                  onPressed: _addPlacemarkPinnedRotated,
                  title: 'Add placemark with pinned direction (Rotated)'
                ),
                ControlButton(
                  onPressed: _blockCameraRotate,
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
