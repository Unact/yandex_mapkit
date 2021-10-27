import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class ClusterizedPlacemarkCollectionPage extends MapPage {
  const ClusterizedPlacemarkCollectionPage() : super('ClusterizedPlacemarkCollection example');

  @override
  Widget build(BuildContext context) {
    return _ClusterizedPlacemarkCollectionExample();
  }
}

class _ClusterizedPlacemarkCollectionExample extends StatefulWidget {
  @override
  _ClusterizedPlacemarkCollectionExampleState createState() => _ClusterizedPlacemarkCollectionExampleState();
}

class _ClusterizedPlacemarkCollectionExampleState extends State<_ClusterizedPlacemarkCollectionExample> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  final MapObjectId clusterizedPlacemarkCollectionId = MapObjectId('clusterized_placemark_collection');

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
                        if (mapObjects.any((el) => el.mapId == clusterizedPlacemarkCollectionId)) {
                          return;
                        }

                        mapObjects.add(ClusterizedPlacemarkCollection(
                          mapId: clusterizedPlacemarkCollectionId,
                          radius: 30,
                          minZoom: 15,
                          onClusterAdded: (ClusterizedPlacemarkCollection self, Cluster cluster) {
                            return cluster.copyWith(
                              appearance: cluster.appearance.copyWith(
                                style: PlacemarkStyle(scale: 1, iconName: 'lib/assets/cluster.png')
                              )
                            );
                          },
                          onClusterTap: (ClusterizedPlacemarkCollection self, Cluster cluster) {
                            print('Tapped cluster');
                          },
                          placemarks: [
                            Placemark(
                              mapId: MapObjectId('placemark1'),
                              point: Point(latitude: 55.756, longitude: 37.618),
                              style: PlacemarkStyle(scale: 1, iconName: 'lib/assets/place.png',)
                            ),
                            Placemark(
                              mapId: MapObjectId('placemark2'),
                              point: Point(latitude: 59.956, longitude: 30.313),
                              style: PlacemarkStyle(scale: 1, iconName: 'lib/assets/place.png',)
                            ),
                          ],
                          onTap: (ClusterizedPlacemarkCollection self, Point point) => print('Tapped me at $point'),
                        ));

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == clusterizedPlacemarkCollectionId)) {
                          return;
                        }

                        final clusterizedPlacemarkCollection = mapObjects
                          .firstWhere((el) => el.mapId == clusterizedPlacemarkCollectionId) as ClusterizedPlacemarkCollection;
                        mapObjects[mapObjects.indexOf(clusterizedPlacemarkCollection)] =
                          clusterizedPlacemarkCollection.copyWith(placemarks: [
                            Placemark(
                              mapId: MapObjectId('placemark_new'),
                              point: Point(latitude: 59.945933, longitude: 30.320045),
                              style: PlacemarkStyle(scale: 1, iconName: 'lib/assets/place.png',)
                            ),
                            Placemark(
                              mapId: MapObjectId('placemark2'),
                              point: Point(latitude: 59.956, longitude: 30.313),
                              style: PlacemarkStyle(scale: 1, iconName: 'lib/assets/place.png',)
                            ),
                          ]);

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        mapObjects.removeWhere((el) => el.mapId == clusterizedPlacemarkCollectionId);

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
