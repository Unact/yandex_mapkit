import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class CirclePage extends MapPage {
  const CirclePage() : super('Circle example');

  @override
  Widget build(BuildContext context) {
    return _CircleExample();
  }
}

class _CircleExample extends StatefulWidget {
  @override
  _CircleExampleState createState() => _CircleExampleState();
}

class _CircleExampleState extends State<_CircleExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId circleId = MapObjectId('circle');

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
                        if (mapObjects.any((el) => el.mapId == circleId)) {
                          return;
                        }

                        final circle = Circle(
                          mapId: circleId,
                          center: const Point(latitude: 55.781863, longitude: 37.451159),
                          radius: 1000000,
                          strokeColor: Colors.blue[700]!,
                          strokeWidth: 5,
                          fillColor: Colors.blue[300]!,
                          onTap: (Circle self, Point point) => print('Tapped me at $point'),
                        );

                        setState(() {
                          mapObjects.add(circle);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == circleId)) {
                          return;
                        }

                        final circle = mapObjects.firstWhere((el) => el.mapId == circleId) as Circle;
                        setState(() {
                          mapObjects[mapObjects.indexOf(circle)] = circle.copyWith(radius: circle.radius - 10000);
                        });
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == circleId);
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
