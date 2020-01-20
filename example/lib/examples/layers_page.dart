import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/page.dart';

class LayersPage extends Page {
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
                        await PermissionHandler().requestPermissions(<PermissionGroup>[PermissionGroup.location]);
                        await controller.showUserLayer(
                          iconName: 'lib/assets/user.png',
                          arrowName: 'lib/assets/arrow.png',
                          accuracyCircleFillColor: Colors.green.withOpacity(0.5));
                      },
                      child: const Text('Show user layer')
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await controller.hideUserLayer();
                      },
                      child: const Text('Hide user layer')
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        await PermissionHandler().requestPermissions(<PermissionGroup>[PermissionGroup.location]);
                        await controller.moveToUser();
                      },
                      child: const Text('Move to user')
                    ),
                    FlatButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: null,
                      child: const Text('')
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
