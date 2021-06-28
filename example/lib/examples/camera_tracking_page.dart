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
  YandexMapController? controller;

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
                        final currentCameraTracking = await controller!.enableCameraTracking(
                          onCameraPositionChange: cameraPositionChanged,
                          style: const PlacemarkStyle(iconName: 'lib/assets/place.png', opacity: 0.5),
                        );
                        await addPlacemark(currentCameraTracking);
                      },
                      title: 'Tracking'
                    ),
                    ControlButton(
                      onPressed: () async {
                        final currentCameraTracking = await controller!.enableCameraTracking(
                          onCameraPositionChange: cameraPositionChanged
                        );
                        await addPlacemark(currentCameraTracking);
                      },
                      title: 'Tracking (without marker)'
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        await controller!.disableCameraTracking();
                      },
                      title: 'Disable tracking'
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
      await addPlacemark(Point(latitude: arguments['latitude'], longitude: arguments['longitude']));
    }
  }

  Future<void> addPlacemark(Point point) async {
    await controller!.addPlacemark(Placemark(
      point: point,
      style: const PlacemarkStyle(
        iconName: 'lib/assets/user.png',
        opacity: 0.9,
      ),
    ));
  }
}
