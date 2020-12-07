import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';

class RoutingPage extends MapPage {
  const RoutingPage() : super('Routing example');

  @override
  Widget build(BuildContext context) {
    return _RoutingExample();
  }
}

class _RoutingExample extends StatefulWidget {
  @override
  _RoutingExampleState createState() => _RoutingExampleState();
}

class _RoutingExampleState extends State<_RoutingExample> {
  YandexMapController controller;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;
  final Point destinationPoint =
      const Point(latitude: 54.763562684662965, longitude: 83.09243331767586);

  String routesInfo = '';

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final List<PermissionGroup> permissions = <PermissionGroup>[
      PermissionGroup.location
    ];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    setState(() {
      _permissionStatus = permissionRequestResult[PermissionGroup.location];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: YandexMap(
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;
            },
          )),
          const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    if (_permissionStatus == PermissionStatus.granted) {
                      await controller.routeToLocation(
                          destination: destinationPoint,
                          placemarkStyle: PlacemarkStyle(
                              opacity: 0.7, iconName: 'lib/assets/place.png'),
                          drivingRoutesCallback: (dynamic msg) {
                            setState(() {
                              routesInfo =
                                  'distance: ${msg['distance']}, time: ${msg['time']}, timeWithTraffic: ${msg['timeWithTraffic']}';
                            });
                          },
                          errorCallback: (dynamic msg) => _showMessage(
                              context, const Text('Error on driving routes')));
                    } else {
                      _showMessage(context,
                          const Text('Location permission was NOT granted'));
                    }
                  },
                  child: const Text('Route'),
                ),
                RaisedButton(
                  onPressed: () async {
                    await controller.cancelRoute();
                  },
                  child: const Text('Cancel route'),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                    child: Text(
                  routesInfo,
                  style: const TextStyle(color: Colors.black),
                ))
              ],
            )
          ])))
        ]);
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
}
