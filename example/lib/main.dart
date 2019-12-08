import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit_example/dummy_image_data.dart' show rawImageData;

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
    onTap: (double latitude, double longitude) => print('Tapped me at $latitude,$longitude'),
  );

  final Placemark _placemarkWithDynamicIcon = Placemark(
    point: const Point(latitude: 30.320045, longitude: 59.945933),
    opacity: 0.95,
    rawImageData: rawImageData,
    onTap: (double latitude, double longitude) => print('Tapped me at $latitude,$longitude'),
  );

  final Polyline _polyline = Polyline(
    coordinates: const <Point>[
      Point(latitude: 59.945933, longitude: 30.320045),
      Point(latitude: 55.75222, longitude: 37.88398),
      Point(latitude: 59.2239, longitude: 39.88398),
      Point(latitude: 56.32867, longitude: 44.00205),
      Point(latitude: 61.67642, longitude: 50.80994),
      Point(latitude: 61.823618, longitude: 56.823571),
      Point(latitude: 60.15328, longitude: 59.95205),
      Point(latitude: 56.8519, longitude: 60.6122),
      Point(latitude: 54.74306, longitude: 55.96779),
      Point(latitude: 55.78874, longitude: 49.12214),
      Point(latitude: 58.59665, longitude: 49.66007),
      Point(latitude: 60.44498, longitude: 50.9968),
      Point(latitude: 63.206777, longitude: 59.750022),
      Point(latitude: 57.15222, longitude: 65.52722),
      Point(latitude: 61.25, longitude: 73.41667),
      Point(latitude: 55.0415, longitude: 82.9346),
      Point(latitude: 66.42989, longitude: 112.4021),
    ],
    strokeColor: Colors.orange[700],
    strokeWidth: 7.5, // <- default value 5.0, this will be a little bold
    outlineColor: Colors.yellow[200],
    outlineWidth: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('YandexMapkit Plugin')
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Placemark with Assets Icon:'),
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
            const Text('Placemark with Binary Icon:'),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.addPlacemark(_placemarkWithDynamicIcon);
                  },
                  child: const Text('Add placemark')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.removePlacemark(_placemarkWithDynamicIcon);
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
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.addPolyline(_polyline);
                  },
                  child: const Text('Add polyline'),
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapController.removePolyline(_polyline);
                  },
                  child: const Text('Remove polyline'),
                )
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
