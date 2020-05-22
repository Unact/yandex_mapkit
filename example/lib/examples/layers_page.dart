import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';

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
  YandexMapController controller;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final List<PermissionGroup> permissions = <PermissionGroup>[PermissionGroup.location];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    setState(() {
      _permissionStatus = permissionRequestResult[PermissionGroup.location];
    });
  }

  void _showMessage(BuildContext context, Text text) {
    final ScaffoldState scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: text,
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
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
                    RaisedButton(
                      onPressed: () async {
                        if (_permissionStatus == PermissionStatus.granted) {
                          await controller.showUserLayer(
                            iconName: 'lib/assets/user.png',
                            arrowName: 'lib/assets/arrow.png',
                            accuracyCircleFillColor: Colors.green.withOpacity(0.5)
                          );
                        } else {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                        }
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
                        if (_permissionStatus == PermissionStatus.granted) {
                          await controller.moveToUser();
                        } else {
                          _showMessage(context, const Text('Location permission was NOT granted'));
                        }
                      },
                      child: const Text('Move to user')
                    ),
                    const FlatButton(
                      padding: EdgeInsets.all(4),
                      onPressed: null,
                      child: Text('')
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
