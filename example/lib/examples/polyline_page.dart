import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class PolylinePage extends MapPage {
  const PolylinePage() : super('Polyline example');

  @override
  Widget build(BuildContext context) {
    return _PolylineExample();
  }
}

class _PolylineExample extends StatefulWidget {
  @override
  _PolylineExampleState createState() => _PolylineExampleState();
}

class _PolylineExampleState extends State<_PolylineExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId polylineId = MapObjectId('polyline');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: YandexMap(
            mapObjects: mapObjects
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
                        if (mapObjects.any((el) => el.mapId == polylineId)) {
                          return;
                        }

                        final polyline = Polyline(
                          mapId: polylineId,
                          coordinates: <Point>[
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
                          strokeColor: Colors.orange[700]!,
                          strokeWidth: 7.5, // default value 5.0, this will be a little bold
                          outlineColor: Colors.yellow[200]!,
                          outlineWidth: 2.0,
                          onTap: (Polyline self, Point point) => print('Tapped me at $point'),
                        );

                        setState(() {
                          mapObjects.add(polyline);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == polylineId)) {
                          return;
                        }

                        final polyline = mapObjects.firstWhere((el) => el.mapId == polylineId) as Polyline;

                        setState(() {
                          mapObjects[mapObjects.indexOf(polyline)] = polyline.copyWith(
                            strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                            strokeWidth: 8.5
                          );
                        });
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == polylineId);
                        });
                      },
                      title: 'Remove'
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
