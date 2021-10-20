import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/data/dummy_image.dart' show rawImageData;
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class PlacemarkPage extends MapPage {
  const PlacemarkPage() : super('Placemark example');

  @override
  Widget build(BuildContext context) {
    return placemarkExample();
  }
}

class placemarkExample extends StatefulWidget {
  @override
  placemarkExampleState createState() => placemarkExampleState();
}

class placemarkExampleState extends State<placemarkExample> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  final PlacemarkId placemarkId = PlacemarkId('normal_icon_placemark');
  final PlacemarkId placemarkWithDynamicIconId = PlacemarkId('dynamic_icon_placemark');

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
        SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('Placemark with Assets Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == placemarkId)) {
                          return;
                        }

                        mapObjects.add(Placemark(
                          placemarkId: placemarkId,
                          point: Point(latitude: 59.945933, longitude: 30.320045),
                          onTap: (Placemark self, Point point) => print('Tapped me at $point'),
                          style: PlacemarkStyle(
                            opacity: 0.7,
                            iconName: 'lib/assets/place.png',
                          ),
                        ));

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == placemarkId)) {
                          return;
                        }

                        final placemark = mapObjects.firstWhere((el) => el.mapId == placemarkId) as Placemark;
                        mapObjects[mapObjects.indexOf(placemark)] = placemark.copyWith(
                          point: Point(
                            latitude: placemark.point.latitude - 1,
                            longitude: placemark.point.longitude - 1
                          )
                        );

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        mapObjects.removeWhere((el) => el.mapId == placemarkId);

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Remove'
                    ),
                  ],
                ),
                Text('Placemark with Binary Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == placemarkWithDynamicIconId)) {
                          return;
                        }

                        mapObjects.add(Placemark(
                          placemarkId: placemarkWithDynamicIconId,
                          point: Point(latitude: 30.320045, longitude: 59.945933),
                          onTap: (Placemark self, Point point) => print('Tapped me at $point'),
                          style: PlacemarkStyle(
                            opacity: 0.95,
                            rawImageData: rawImageData,
                          ),
                        ));

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == placemarkWithDynamicIconId)) {
                          return;
                        }

                        final placemarkWithDynamicIcon = mapObjects
                          .firstWhere((el) => el.mapId == placemarkWithDynamicIconId) as Placemark;
                        mapObjects[mapObjects.indexOf(placemarkWithDynamicIcon)] = placemarkWithDynamicIcon.copyWith(
                          point: Point(
                            latitude: placemarkWithDynamicIcon.point.latitude + 1,
                            longitude: placemarkWithDynamicIcon.point.longitude + 1
                          )
                        );

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        mapObjects.removeWhere((el) => el.mapId == placemarkWithDynamicIconId);

                        await controller.updateMapObjects(mapObjects);
                      },
                      title: 'Remove'
                    ),
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
