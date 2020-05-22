import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';

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
  YandexMapController controller;
  final Polygon polygon = Polygon(
    coordinates: const <Point>[
      Point(latitude: 56.34295, longitude: 74.62829),
      Point(latitude: 70.12669, longitude: 98.97399),
      Point(latitude: 56.04956, longitude: 125.07751),
    ],
    strokeColor: Colors.orange[700],
    strokeWidth: 3.0,
    fillColor: Colors.yellow[200],
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
                    RaisedButton(
                      onPressed: () async {
                        await controller.addPolygon(polygon);
                      },
                      child: const Text('Add'),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await controller.removePolygon(polygon);
                      },
                      child: const Text('Remove'),
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
