import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/map_page.dart';

class MapControlsPage extends MapPage {
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
  bool isNightModeEnabled = false;
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  final String emptyStyle = '''
    [
      {
        "tags": {
          "all": ["landscape"]
        },
        "stylers": {
          "saturation": 0,
          "lightness": 0
        }
      }
    ]
  ''';
  final String nonEmptyStyle = '''
    [
      {
        "tags": {
          "all": ["landscape"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';
  double _height = 0;

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
            onMapRendered: () => print('Map rendered'),
            onMapSizeChanged: (MapSize size) => print('Map size changed to ${size.width}x${size.height}'),
            onMapTap: (Point point) => print('Tapped map at ${point.latitude},${point.longitude}'),
            onMapLongTap: (Point point) => print('Long tapped map at ${point.latitude},${point.longitude}')
          )
        ),
        SizedBox(height: _height),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              children: <TableRow>[
                TableRow(children: <Widget>[
                  _button(
                    onPressed: () async {
                      await controller.setBounds(
                        southWestPoint: const Point(latitude: 60.0, longitude: 30.0),
                        northEastPoint: const Point(latitude: 65.0, longitude: 40.0),
                      );
                    },
                    title: 'Set bounds'
                  ),
                  _button(
                    onPressed: () async {
                      await controller.move(
                        point: _point,
                        animation: const MapAnimation(smooth: true, duration: 2.0)
                      );
                    },
                    title: 'Move'
                  ),
                ]),
                TableRow(children: <Widget>[
                  _button(
                    onPressed: () => controller.zoomIn(),
                    title: 'Zoom in'
                  ),
                  _button(
                    onPressed: () => controller.zoomOut(),
                    title: 'Zoom out'
                  ),
                ]),
                TableRow(children: <Widget>[
                  _button(
                    onPressed: () async {
                      await controller.addPlacemark(
                        Placemark(
                          point: await controller.getTargetPoint(),
                          opacity: 0.7,
                          iconName: 'lib/assets/place.png'
                        )
                      );
                    },
                    title: 'Target point'
                  ),
                  _button(
                    onPressed: () async {
                      await controller.logoAlignment(
                        horizontal: HorizontalAlignment.center,
                        vertical: VerticalAlignment.bottom
                      );
                    },
                    title: 'Logo position'
                  ),
                ]),
                TableRow(children: <Widget>[
                  _button(
                    onPressed: () async {
                      await controller.setMapStyle(style: nonEmptyStyle);
                    },
                    title: 'Set Style'
                  ),
                  _button(
                    onPressed: () async {
                      await controller.setMapStyle(style: emptyStyle);
                    },
                    title: 'Remove style'
                  ),
                ]),
                TableRow(children: <Widget>[
                  _button(
                    onPressed: () async {
                      isNightModeEnabled = !isNightModeEnabled;
                      await controller.toggleNightMode(enabled: isNightModeEnabled);
                    },
                    title: 'Night mode'
                  ),
                  _button(
                    onPressed: () async {
                      setState(() {
                        _height = _height == 0 ? 10 : 0;
                      });
                    },
                    title: 'Change size'
                  )
                ]),
              ],
            ),
          ),
        )
      ]
    );
  }

  Widget _button({
    @required Function() onPressed,
    @required String title
  }){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RaisedButton(
        child: Text(title),
        onPressed: onPressed
      ),
    );
  }
}
