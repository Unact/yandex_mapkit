import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/data/dummy_image.dart' show rawImageData;
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class PlacemarkPage extends MapPage {
  const PlacemarkPage() : super('Placemark example');

  @override
  Widget build(BuildContext context) {
    return _PlacemarkExample();
  }
}

class _PlacemarkExample extends StatefulWidget {
  @override
  _PlacemarkExampleState createState() => _PlacemarkExampleState();
}

class _PlacemarkExampleState extends State<_PlacemarkExample> {

  YandexMapController? controller;

  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  static const _points = [
    Point(latitude: 63.945933, longitude: 49.320045),
    Point(latitude: 63.945933, longitude: 59.320045),
    Point(latitude: 63.945933, longitude: 69.320045),
    Point(latitude: 63.945933, longitude: 79.320045),
    Point(latitude: 63.945933, longitude: 89.320045),
    Point(latitude: 63.945933, longitude: 99.320045),
    Point(latitude: 63.945933, longitude: 109.320045),
    Point(latitude: 63.945933, longitude: 119.320045),
    Point(latitude: 63.945933, longitude: 129.320045),
    Point(latitude: 63.945933, longitude: 139.320045),
  ];

  final Placemark _placemark = Placemark(
    point: _point,
    onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
    icon: PlacemarkIcon.fromIconName(
      iconName: 'lib/assets/place.png',
    ),
    opacity: 0.7,
  );

  final Placemark _placemarkWithDynamicIcon = Placemark(
    point: const Point(latitude: 30.320045, longitude: 59.945933),
    onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
    icon: PlacemarkIcon.fromRawImageData(
      rawImageData: rawImageData,
    ),
    opacity: 0.95,
  );

  final Placemark _compositeIconPlacemark = Placemark(
    point: const Point(latitude: 34.820045, longitude: 45.945933),
    onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
    compositeIcon: {
      'user': PlacemarkIcon.fromIconName(
        iconName: 'lib/assets/user.png',
        style: PlacemarkStyle(
          anchor: Point(
            latitude: 0.5,
            longitude: 0.5,
          ),
        ),
      ),
      'arrow': PlacemarkIcon.fromIconName(
        iconName: 'lib/assets/arrow.png',
        style: PlacemarkStyle(
          anchor: Point(
            latitude: 0.5,
            longitude: 1.5,
          ),
        ),
      ),
    }
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
                const Text('Placemark with Assets Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        await controller!.addPlacemark(_placemark);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller!.removePlacemark(_placemark);
                      },
                      title: 'Remove'
                    ),
                  ],
                ),
                const Text('Placemark with Binary Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        await controller!.addPlacemark(_placemarkWithDynamicIcon);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller!.removePlacemark(_placemarkWithDynamicIcon);
                      },
                      title: 'Remove'
                    ),
                  ],
                ),
                const Text('Placemark with Composite Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          await controller!.addPlacemark(_compositeIconPlacemark);
                        },
                        title: 'Add'
                    ),
                    ControlButton(
                        onPressed: () async {
                          await controller!.removePlacemark(_compositeIconPlacemark);
                        },
                        title: 'Remove'
                    ),
                  ],
                ),
                const Text('Multi add and clear'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                        onPressed: () async {
                          await controller!.addPlacemarks(
                            points: _points,
                            icon: PlacemarkIcon.fromIconName(
                              iconName: 'lib/assets/place.png',
                            ),
                          );
                        },
                        title: 'Add'
                    ),
                    ControlButton(
                        onPressed: () async {

                          await controller!.addPlacemarks(
                            points: _points,
                            icon: PlacemarkIcon.fromIconName(
                              iconName: 'lib/assets/place.png',
                            ),
                            isClusterized: true,
                          );

                          await controller!.clusterPlacemarks(
                            clusterRadius: 100,
                            minZoom: 17,
                            addedCallback: (hashValue) {
                              controller!.setClusterIcon(
                                  hashValue: hashValue,
                                  icon: PlacemarkIcon.fromIconName(
                                    iconName: 'lib/assets/arrow.png',
                                  )
                              );
                            },
                            tapCallback: (cluster) {
                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                title: const Text('Cluster tapped'),
                                content: Text('Size: ${cluster.size}'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ));
                            },
                          );
                        },
                        title: 'Add with clusters'
                    ),
                    ControlButton(
                        onPressed: () async {
                          await controller!.clear();
                        },
                        title: 'Clear all'
                    ),
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
