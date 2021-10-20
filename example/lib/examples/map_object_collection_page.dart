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
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  final MapObjectCollectionId mapObjectCollectionId = MapObjectCollectionId('map_object_collection');

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
                        if (mapObjects.any((el) => el.mapId == mapObjectCollectionId)) {
                          return;
                        }

                        mapObjects.add(MapObjectCollection(
                          mapObjectCollectionId: mapObjectCollectionId,
                          mapObjects: [
                            Circle(
                              circleId: CircleId('circle'),
                              center: Point(latitude: 59.945933, longitude: 30.320045),
                              radius: 100000
                            ),
                            Placemark(
                              placemarkId: PlacemarkId('placemark'),
                              point: Point(latitude: 59.945933, longitude: 30.320045)
                            ),
                            MapObjectCollection(
                              mapObjectCollectionId: MapObjectCollectionId('inner_map_object_collection'),
                              mapObjects: [
                                Placemark(
                                  placemarkId: PlacemarkId('inner_placemark'),
                                  point: Point(latitude: 57.945933, longitude: 28.320045),
                                  style:PlacemarkStyle(
                                    opacity: 0.7,
                                    iconName: 'lib/assets/place.png',
                                  ),
                                )
                              ]
                            )
                          ],
                          onTap: (MapObjectCollection self, Point point) => print('Tapped me at $point'),
                        ));

                        await controller.updateMapObjects(mapObjects);
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
                        mapObjects[mapObjects.indexOf(mapObjectCollection)] = mapObjectCollection.copyWith(mapObjects: [
                          Circle(
                            circleId: CircleId('circle'),
                            center: Point(latitude: 59.945933, longitude: 30.320045),
                            radius: 10000
                          ),
                          Placemark(
                            placemarkId: PlacemarkId('placemark_new'),
                            point: Point(latitude: 59.945933, longitude: 30.320045),
                            style: PlacemarkStyle(scale: 0.2, iconName: 'lib/assets/arrow.png',)
                          ),
                        ]);

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        mapObjects.removeWhere((el) => el.mapId == mapObjectCollectionId);

                        await controller.updateMapObjects(mapObjects);
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
