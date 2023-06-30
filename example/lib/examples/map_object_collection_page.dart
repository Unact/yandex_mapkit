import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class MapObjectCollectionPage extends MapPage {
  const MapObjectCollectionPage({Key? key}) : super('MapObjectCollection example', key: key);

  @override
  Widget build(BuildContext context) {
    return _MapObjectCollectionExample();
  }
}

class _MapObjectCollectionExample extends StatefulWidget {
  @override
  _MapObjectCollectionExampleState createState() => _MapObjectCollectionExampleState();
}

class _MapObjectCollectionExampleState extends State<_MapObjectCollectionExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectId = const MapObjectId('map_object_collection');

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

                        final mapObject = MapObjectCollection(
                          mapId: mapObjectId,
                          mapObjects: [
                            CircleMapObject(
                              mapId: const MapObjectId('circle'),
                              circle: const Circle(
                                radius: 100000,
                                center: Point(latitude: 59.945933, longitude: 30.320045)
                              ),
                              consumeTapEvents: true,
                              onTap: (CircleMapObject self, Point point) => print('Tapped circle at $point'),
                            ),
                            const PlacemarkMapObject(
                              mapId: MapObjectId('placemark'),
                              point: Point(latitude: 59.945933, longitude: 30.320045)
                            ),
                            MapObjectCollection(
                              mapId: const MapObjectId('inner_map_object_collection'),
                              mapObjects: [
                                PlacemarkMapObject(
                                  mapId: const MapObjectId('inner_placemark'),
                                  point: const Point(latitude: 57.945933, longitude: 28.320045),
                                  opacity: 0.7,
                                  icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                    image: BitmapDescriptor.fromAssetImage('lib/assets/place.png')
                                  ))
                                )
                              ]
                            )
                          ],
                          onTap: (MapObjectCollection self, Point point) => print('Tapped me at $point'),
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

                        final mapObject = mapObjects.firstWhere((el) => el.mapId == mapObjectId) as MapObjectCollection;

                        setState(() {
                          mapObjects[mapObjects.indexOf(mapObject)] = mapObject.copyWith(mapObjects: [
                            CircleMapObject(
                              mapId: const MapObjectId('circle'),
                              circle: const Circle(
                                radius: 10000,
                                center: Point(latitude: 59.945933, longitude: 30.320045)
                              ),
                              consumeTapEvents: true,
                              onTap: (CircleMapObject self, Point point) => print('Tapped circle at $point'),
                            ),
                            PlacemarkMapObject(
                              mapId: const MapObjectId('placemark_new'),
                              point: const Point(latitude: 59.945933, longitude: 30.320045),
                              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/arrow.png'),
                                scale: 0.2,
                              ))
                            ),
                          ]);
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
