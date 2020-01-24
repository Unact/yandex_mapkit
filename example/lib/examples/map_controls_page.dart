import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/page.dart';

class MapControlsPage extends Page {
  const MapControlsPage() : super('Map controls example');

  @override
  Widget build(BuildContext context) {
    return _MapControlsExample();
  }
}

class _MapControlsExample extends StatefulWidget {
  @override
  _MapControlsExampleState createState() => _MapControlsExampleState();
}

class _MapControlsExampleState extends State<_MapControlsExample> {
  YandexMapController controller;
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  final String emptyStyle = '''
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
  ''';
  final String nonEmptyStyle = '''
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
  ''';

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
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.setBounds(
                          southWestPoint: const Point(latitude: 60.0, longitude: 30.0),
                          northEastPoint: const Point(latitude: 65.0, longitude: 40.0),
                        );
                      },
                      child: const Text('Set bounds')
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.move(
                          point: _point,
                          animation: const MapAnimation(smooth: true, duration: 2.0)
                        );
                      },
                      child: const Text('Move')
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.zoomIn();
                      },
                      child: const Text('Zoom in')
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.zoomOut();
                      },
                      child: const Text('Zoom out')
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.addPlacemark(
                          Placemark(
                            point: await controller.getTargetPoint(),
                            opacity: 0.7,
                            iconName: 'lib/assets/place.png'
                          )
                        );
                      },
                      child: const Text('Target point')
                    ),
                    const FlatButton(
                      padding: EdgeInsets.all(4),
                      onPressed: null,
                      child: Text('')
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.setMapStyle(style: nonEmptyStyle);
                      },
                      child: const Text('Set Style')
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        await controller.setMapStyle(style: emptyStyle);
                      },
                      child: const Text('Remove style')
                    )
                  ],
                ),
              ]
            )
          )
        )
      ]
    );
  }
}
