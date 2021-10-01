import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class PolygonPage extends MapPage {
  const PolygonPage() : super('Polygon example');

  @override
  Widget build(BuildContext context) {
    return _PolygonExample();
  }
}

class _PolygonExample extends StatefulWidget {
  @override
  _PolygonExampleState createState() => _PolygonExampleState();
}

class _PolygonExampleState extends State<_PolygonExample> {
  late YandexMapController controller;
  final Polygon polygon = Polygon(
    outerRingCoordinates: const <Point>[
      Point(latitude: 56.34295, longitude: 74.62829),
      Point(latitude: 70.12669, longitude: 98.97399),
      Point(latitude: 56.04956, longitude: 125.07751),
    ],
    innerRingsCoordinates: const <List<Point>>[
      <Point>[
        Point(latitude: 57.34295, longitude: 78.62829),
        Point(latitude: 69.12669, longitude: 98.97399),
        Point(latitude: 57.04956, longitude: 121.07751),
      ]
    ],
    style: PolygonStyle(
      strokeColor: Colors.orange[700]!,
      strokeWidth: 3.0,
      fillColor: Colors.yellow[200]!,
    ),
    onTap: (Polygon self, Point point) => print('Tapped me at $point'),
  );

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
                        await controller.addPolygon(polygon);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller.removePolygon(polygon);
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
