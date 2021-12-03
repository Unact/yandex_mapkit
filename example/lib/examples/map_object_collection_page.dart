import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class MapObjectCollectionPage extends MapPage {
  const MapObjectCollectionPage() : super('MapObjectCollection example');

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

  final MapObjectId mapObjectCollectionId = MapObjectId('map_object_collection');

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
                        if (mapObjects.any((el) => el.mapId == mapObjectCollectionId)) {
                          return;
                        }

                        final mapObjectCollection = MapObjectCollection(
                          mapId: mapObjectCollectionId,
                          mapObjects: [
                            Circle(
                              mapId: MapObjectId('circle'),
                              center: Point(latitude: 59.945933, longitude: 30.320045),
                              radius: 100000,
                              consumeTapEvents: true,
                              onTap: (Circle self, Point point) => print('Tapped circle at $point'),
                            ),
                            Placemark(
                              mapId: MapObjectId('placemark'),
                              point: Point(latitude: 59.945933, longitude: 30.320045)
                            ),
                            MapObjectCollection(
                              mapId: MapObjectId('inner_map_object_collection'),
                              mapObjects: [
                                Placemark(
                                  mapId: MapObjectId('inner_placemark'),
                                  point: Point(latitude: 57.945933, longitude: 28.320045),
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
                          mapObjects.add(mapObjectCollection);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == mapObjectCollectionId)) {
                          return;
                        }

                        final mapObjectCollection = mapObjects
                          .firstWhere((el) => el.mapId == mapObjectCollectionId) as MapObjectCollection;

                        setState(() {
                          mapObjects[mapObjects.indexOf(mapObjectCollection)] = mapObjectCollection.copyWith(mapObjects: [
                            Circle(
                              mapId: MapObjectId('circle'),
                              center: Point(latitude: 59.945933, longitude: 30.320045),
                              radius: 10000,
                              consumeTapEvents: true,
                              onTap: (Circle self, Point point) => print('Tapped circle at $point'),
                            ),
                            Placemark(
                              mapId: MapObjectId('placemark_new'),
                              point: Point(latitude: 59.945933, longitude: 30.320045),
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
                          mapObjects.removeWhere((el) => el.mapId == mapObjectCollectionId);
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
