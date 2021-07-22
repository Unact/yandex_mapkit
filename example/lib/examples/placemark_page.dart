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

  ObjectsCollection? _clusterizedCollection;

  ObjectsCollection? _collection1;
  ObjectsCollection? _collection2;
  ObjectsCollection? _collection3;

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
                        await controller!.addPlacemark(_placemark); // Add to the root collection (mapObjects)
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
                        await controller!.addPlacemark(_placemarkWithDynamicIcon);  // Add to the root collection (mapObjects)
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
                          await controller!.addPlacemark(_compositeIconPlacemark);  // Add to the root collection (mapObjects)
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

                          _collection1 ??= ObjectsCollection();
                          _collection2 ??= ObjectsCollection(parentId: _collection1!.id); // Collection 2 is nested in Collection 1
                          _collection3 ??= ObjectsCollection(parentId: _collection2!.id); // Collection 3 is nested in Collection 2

                          await controller!.addCollection(_collection1!);
                          await controller!.addCollection(_collection2!);
                          await controller!.addCollection(_collection3!);

                          // Collection 1
                          await controller!.addPlacemark(
                            Placemark(
                              point: const Point(latitude: 30.320045, longitude: 59.945933),
                              onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
                              icon: PlacemarkIcon.fromRawImageData(
                                rawImageData: rawImageData,
                              ),
                              opacity: 0.95,
                              collectionId: _collection1!.id,
                            ),
                          );

                          // Collection 2
                          await controller!.addPlacemarks(
                            points: _points,
                            icon: PlacemarkIcon.fromIconName(
                              iconName: 'lib/assets/place.png',
                            ),
                            collectionId: _collection2!.id,
                          );

                          // Collection 3
                          await controller!.addPlacemark(
                            Placemark(
                              point: _point,
                              onTap: (Placemark self, Point point) => print('Tapped me at ${point.latitude},${point.longitude}'),
                              icon: PlacemarkIcon.fromIconName(
                                iconName: 'lib/assets/place.png',
                              ),
                              opacity: 0.7,
                              collectionId: _collection3!.id,
                            ),
                          );
                        },
                        title: 'Add'
                    ),
                    ControlButton(
                        onPressed: () async {

                          // Create and add clusterized collection - required for placemarks clusters to work (will not work with plain collection, including root)
                          _clusterizedCollection ??= ObjectsCollection(isClusterized: true);
                          await controller!.addCollection(_clusterizedCollection!);

                          await controller!.addPlacemarks(
                            points: _points,
                            icon: PlacemarkIcon.fromIconName(
                              iconName: 'lib/assets/place.png',
                            ),
                            collectionId: _clusterizedCollection!.id, // Specify collectionId here
                          );

                          // Must call this method to show clusterized placemarks
                          await controller!.clusterPlacemarks(
                            collectionId: _clusterizedCollection!.id, // Corresponding collectionId must be provided
                            clusterRadius: 100,
                            minZoom: 17,
                            addedCallback: (cluster) {
                              controller!.setClusterIcon(
                                  hashValue: cluster.hashValue,
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
                          await controller!.clear(); // Clears root (mapObjects) collection containing all map objects. You can pass a concrete collectionId.
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
