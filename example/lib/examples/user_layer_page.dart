import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class UserLayerPage extends MapPage {
  const UserLayerPage() : super('User layer example');

  @override
  Widget build(BuildContext context) {
    return _UserLayerExample();
  }
}

class _UserLayerExample extends StatefulWidget {
  @override
  _UserLayerExampleState createState() => _UserLayerExampleState();
}

class _UserLayerExampleState extends State<_UserLayerExample> {
  late YandexMapController controller;

  Future<bool> get locationPermissionNotGranted async => !(await Permission.location.request().isGranted);

  void _showMessage(BuildContext context, Text text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
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
            onUserLocationAdded: (UserLocationView view) async {
              return view.copyWith(
                pin: view.pin.copyWith(
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('lib/assets/user.png'))
                  )
                ),
                arrow: view.arrow.copyWith(
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('lib/assets/arrow.png'))
                  )
                ),
                accuracyCircle: view.accuracyCircle.copyWith(
                  fillColor: Colors.green.withOpacity(0.5)
                )
              );
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
                        if (await locationPermissionNotGranted) {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                          return;
                        }

                        await controller.toggleUserLayer(visible: true);
                      },
                      title:'Show user layer'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (await locationPermissionNotGranted) {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                          return;
                        }

                        await controller.toggleUserLayer(visible: false);
                      },
                      title:'Hide user layer'
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (await locationPermissionNotGranted) {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                          return;
                        }

                        print(await controller.getUserCameraPosition());
                      },
                      title: 'Get user camera position'
                    )
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
