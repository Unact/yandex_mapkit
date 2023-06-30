import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class CircleMapObjectPage extends MapPage {
  const CircleMapObjectPage({Key? key}) : super('Circle example', key: key);

  @override
  Widget build(BuildContext context) {
    return _CircleMapObjectExample();
  }
}

class _CircleMapObjectExample extends StatefulWidget {
  @override
  _CircleMapObjectExampleState createState() => _CircleMapObjectExampleState();
}

class _CircleMapObjectExampleState extends State<_CircleMapObjectExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectId = const MapObjectId('circle');

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
                        if (mapObjects.any((el) => el.mapId == mapObjectId)) {
                          return;
                        }

                        final mapObject = CircleMapObject(
                          mapId: mapObjectId,
                          circle: const Circle(
                            center: Point(latitude: 55.781863, longitude: 37.451159),
                            radius: 1000000
                          ),
                          strokeColor: Colors.blue[700]!,
                          strokeWidth: 5,
                          fillColor: Colors.blue[300]!,
                          onTap: (CircleMapObject self, Point point) => print('Tapped me at $point'),
                        );

                        setState(() {
                          mapObjects.add(mapObject);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == mapObjectId)) {
                          return;
                        }

                        final mapObject = mapObjects.firstWhere((el) => el.mapId == mapObjectId) as CircleMapObject;
                        setState(() {
                          mapObjects[mapObjects.indexOf(mapObject)] = mapObject.copyWith(
                            fillColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                          );
                        });
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectId);
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
