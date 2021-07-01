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

  YandexMapController? controller;

  final Circle circle = Circle(
    center: const Point(latitude: 55.781863, longitude: 37.451159),
    radius: 1000000,
    style: CircleStyle(
      strokeColor: Colors.blue[700]!,
      strokeWidth: 5,
      fillColor: Colors.blue[300]!,
      isGeodesic: false,
    ),
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
                                  await controller!.addCircle(circle);
                                },
                                title: 'Add'
                            ),
                            ControlButton(
                                onPressed: () async {
                                  await controller!.removeCircle(circle);
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
