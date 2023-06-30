import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class PlacemarkMapObjectPage extends MapPage {
  const PlacemarkMapObjectPage({Key? key}) : super('Placemark example', key: key);

  @override
  Widget build(BuildContext context) {
    return _PlacemarkMapObjectExample();
  }
}

class _PlacemarkMapObjectExample extends StatefulWidget {
  @override
  _PlacemarkMapObjectExampleState createState() => _PlacemarkMapObjectExampleState();
}

class _PlacemarkMapObjectExampleState extends State<_PlacemarkMapObjectExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectId = const MapObjectId('normal_icon_placemark');
  final MapObjectId mapObjectWithDynamicIconId = const MapObjectId('dynamic_icon_placemark');
  final MapObjectId mapObjectWithCompositeIconId = const MapObjectId('composite_icon_placemark');

  Future<Uint8List> _rawPlacemarkImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(50, 50);
    final fillPaint = Paint()
      ..color = Colors.blue[100]!
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const radius = 20.0;

    final circleOffset = Offset(size.height / 2, size.width / 2);

    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

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
                const Text('Placemark with Assets Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == mapObjectId)) {
                          return;
                        }

                        final mapObject = PlacemarkMapObject(
                          mapId: mapObjectId,
                          point: const Point(latitude: 59.945933, longitude: 30.320045),
                          onTap: (PlacemarkMapObject self, Point point) => print('Tapped me at $point'),
                          opacity: 0.7,
                          direction: 90,
                          isDraggable: true,
                          onDragStart: (_) => print('Drag start'),
                          onDrag: (_, Point point) => print('Drag at point $point'),
                          onDragEnd: (_) => print('Drag end'),
                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                            rotationType: RotationType.rotate
                          )),
                          text: const PlacemarkText(
                            text: 'Point',
                            style: PlacemarkTextStyle(
                              placement: TextStylePlacement.top,
                              color: Colors.amber,
                              outlineColor: Colors.black
                            )
                          )
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

                        final mapObject = mapObjects.firstWhere((el) => el.mapId == mapObjectId) as PlacemarkMapObject;

                        setState(() {
                          mapObjects[mapObjects.indexOf(mapObject)] = mapObject.copyWith(
                            point: Point(
                              latitude: mapObject.point.latitude - 1,
                              longitude: mapObject.point.longitude - 1
                            )
                          );
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
                    ),
                  ],
                ),
                const Text('Placemark with Binary Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == mapObjectWithDynamicIconId)) {
                          return;
                        }

                        final mapObjectWithDynamicIcon = PlacemarkMapObject(
                          mapId: mapObjectWithDynamicIconId,
                          point: const Point(latitude: 30.320045, longitude: 59.945933),
                          onTap: (PlacemarkMapObject self, Point point) => print('Tapped me at $point'),
                          isDraggable: true,
                          onDragStart: (_) => print('Drag start'),
                          onDrag: (_, Point point) => print('Drag at point $point'),
                          onDragEnd: (_) => print('Drag end'),
                          opacity: 0.95,
                          icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromBytes(await _rawPlacemarkImage())
                          ))
                        );

                        setState(() {
                          mapObjects.add(mapObjectWithDynamicIcon);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == mapObjectWithDynamicIconId)) {
                          return;
                        }

                        final mapObjectWithDynamicIcon = mapObjects
                          .firstWhere((el) => el.mapId == mapObjectWithDynamicIconId) as PlacemarkMapObject;

                        setState(() {
                          mapObjects[mapObjects.indexOf(mapObjectWithDynamicIcon)] = mapObjectWithDynamicIcon.copyWith(
                            point: Point(
                              latitude: mapObjectWithDynamicIcon.point.latitude + 1,
                              longitude: mapObjectWithDynamicIcon.point.longitude + 1
                            )
                          );
                        });
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectWithDynamicIconId);
                        });
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
                        if (mapObjects.any((el) => el.mapId == mapObjectWithCompositeIconId)) {
                          return;
                        }

                        final mapObjectWithCompositeIcon = PlacemarkMapObject(
                          mapId: mapObjectWithCompositeIconId,
                          point: const Point(latitude: 34.820045, longitude: 45.945933),
                          onTap: (PlacemarkMapObject self, Point point) => print('Tapped me at $point'),
                          isDraggable: true,
                          onDragStart: (_) => print('Drag start'),
                          onDrag: (_, Point point) => print('Drag at point $point'),
                          onDragEnd: (_) => print('Drag end'),
                          icon: PlacemarkIcon.composite([
                            PlacemarkCompositeIconItem(
                              name: 'user',
                              style: PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/user.png'),
                                anchor: const Offset(0.5, 0.5),
                              )
                            ),
                            PlacemarkCompositeIconItem(
                              name: 'arrow',
                              style: PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/arrow.png'),
                                anchor: const Offset(0.5, 1.5),
                              )
                            )
                          ]),
                          opacity: 0.7,
                        );

                        setState(() {
                          mapObjects.add(mapObjectWithCompositeIcon);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == mapObjectWithCompositeIconId)) {
                          return;
                        }

                        final mapObjectWithCompositeIcon = mapObjects
                          .firstWhere((el) => el.mapId == mapObjectWithCompositeIconId) as PlacemarkMapObject;

                        setState(() {
                          mapObjects[mapObjects.indexOf(mapObjectWithCompositeIcon)] = mapObjectWithCompositeIcon
                            .copyWith(
                              point: Point(
                                latitude: mapObjectWithCompositeIcon.point.latitude + 1,
                                longitude: mapObjectWithCompositeIcon.point.longitude + 1
                              )
                            );
                        });
                      },
                      title: 'Update'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectWithCompositeIconId);
                        });
                      },
                      title: 'Remove'
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
