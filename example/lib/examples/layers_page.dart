import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class LayersPage extends MapPage {
  const LayersPage() : super('Layers example');

  @override
  Widget build(BuildContext context) {
    return _LayersExample();
  }
}

class _LayersExample extends StatefulWidget {
  @override
  _LayersExampleState createState() => _LayersExampleState();
}

class _LayersExampleState extends State<_LayersExample> {
  YandexMapController? controller;

  Future<bool> get locationPermissionGranted async => await Permission.location.request().isGranted;

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
                        if (await locationPermissionGranted) {
                          await controller!.showUserLayer(
                            iconName: 'lib/assets/user.png',
                            arrowName: 'lib/assets/arrow.png',
                            accuracyCircleFillColor: Colors.green.withOpacity(0.5)
                          );
                        } else {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                        }
                      },
                      title:'Show user layer'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller!.hideUserLayer();
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
                        if (await locationPermissionGranted) {
                          print(await controller!.getUserTargetPoint());
                        } else {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                        }
                      },
                      title: 'Get user point'
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
