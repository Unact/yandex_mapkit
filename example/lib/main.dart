import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  YandexMapController _yandexMapController;
  final Placemark _placemark = Placemark(
    point: _point,
    opacity: 0.7,
    iconName: 'lib/assets/place.png',
    onTap: (double latitude, double longitude) => print('Tapped me at $latitude,$longitude')
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('YandexMapkit Plugin')
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.addPlacemark(_placemark);
                  },
                  child: const Text('Add placemark')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.removePlacemark(_placemark);
                  },
                  child: const Text('Remove placemark')
                ),
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.setBounds(
                      southWestPoint: const Point(latitude: 60.0, longitude: 30.0),
                      northEastPoint: const Point(latitude: 65.0, longitude: 40.0),
                    );
                  },
                  child: const Text('setBounds')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.move(
                      point: _point,
                      animation: const MapAnimation(smooth: true, duration: 2.0)
                    );
                  },
                  child: const Text('Move')
                ),
              ],
            ),
            Row(
              children: <RaisedButton>[
                RaisedButton(
                  onPressed: () async {
                    await PermissionHandler().requestPermissions(<PermissionGroup>[PermissionGroup.location]);
                    await _yandexMapController.showUserLayer(iconName: 'lib/assets/user.png');
                  },
                  child: const Text('Show User')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.hideUserLayer();
                  },
                  child: const Text('Hide User')
                )
              ],
            ),
            Row(
              children: <RaisedButton>[
                RaisedButton(
                    onPressed: () async {
                      await _yandexMapController.zoomIn();
                    },
                    child: const Text('Zoom In')
                ),
                RaisedButton(
                    onPressed: () async {
                      await _yandexMapController.zoomOut();
                    },
                    child: const Text('Zoom Out')
                ),
                RaisedButton(
                    onPressed: () async {
                      Point targetPoint = await _yandexMapController.getTargetPoint();
                      await _yandexMapController.addPlacemark(Placemark(
                          point: targetPoint,
                          opacity: 0.7,
                          iconName: 'lib/assets/place.png',
                          onTap: (double latitude, double longitude) => print('Tapped me at $latitude,$longitude')
                      ));

                    },
                    child: const Text('getTargetPoint')
                )
              ],
            ),
            Row(
              children: <RaisedButton>[
                RaisedButton(
                    onPressed: () async {
                      await _yandexMapController.setMapStyle(style:
                      '''
                        [
                          {
                            "featureType": "all",
                            "stylers": {
                              "hue": "0.5",
                              "saturation": "0.5",
                              "lightness": "0.5"
                            }
                          }
                        ]
                      '''
                    );
                    },
                    child: const Text('Set Style')
                ),
                RaisedButton(
                    onPressed: () async {
                      await _yandexMapController.setMapStyle(style:
                      '''
                        [
                          {
                            "featureType": "all",
                            "stylers": {
                              "hue": "0",
                              "saturation": "0",
                              "lightness": "0"
                            }
                          }
                        ]
                      '''
                    );
                    },
                    child: const Text('Disable style')
                )
              ],
            ),
            Expanded(
              child: YandexMap(
                onMapCreated: (YandexMapController controller) async {
                  _yandexMapController = controller;

                  await _yandexMapController.removePlacemark(_placemark);
                  await _yandexMapController.addPlacemark(_placemark);
                },
              )
            )
          ]
        ),
      )
    );
  }
}
