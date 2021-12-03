import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

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
  final List<MapObject> mapObjects = [];

  final int kPlacemarkCount = 500;
  final Random seed = Random();
  final MapObjectId clusterizedPlacemarkCollectionId = MapObjectId('clusterized_placemark_collection');
  final MapObjectId largeClusterizedPlacemarkCollectionId = MapObjectId('large_clusterized_placemark_collection');

  Future<Uint8List> _buildClusterAppearance(Cluster cluster) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(200, 200);
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final radius = 60.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: cluster.size.toString(),
        style: TextStyle(color: Colors.black, fontSize: 50)
      ),
      textDirection: TextDirection.ltr
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    final textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);
    final circleOffset = Offset(size.height / 2, size.width / 2);

    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);
    textPainter.paint(canvas, textOffset);

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  double _randomDouble() {
    return (500 - seed.nextInt(1000))/1000;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == clusterizedPlacemarkCollectionId)) {
                          return;
                        }

                        final clusterizedPlacemarkCollection = ClusterizedPlacemarkCollection(
                          mapId: clusterizedPlacemarkCollectionId,
                          radius: 30,
                          minZoom: 15,
                          onClusterAdded: (ClusterizedPlacemarkCollection self, Cluster cluster) async {
                            return cluster.copyWith(
                              appearance: cluster.appearance.copyWith(
                                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromAssetImage('lib/assets/cluster.png'),
                                  scale: 1
                                ))
                              )
                            );
                          },
                          onClusterTap: (ClusterizedPlacemarkCollection self, Cluster cluster) {
                            print('Tapped cluster');
                          },
                          placemarks: [
                            Placemark(
                              mapId: MapObjectId('placemark_1'),
                              point: Point(latitude: 55.756, longitude: 37.618),
                              consumeTapEvents: true,
                              onTap: (Placemark self, Point point) => print('Tapped placemark at $point'),
                              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                scale: 1
                              ))
                            ),
                            Placemark(
                              mapId: MapObjectId('placemark_2'),
                              point: Point(latitude: 59.956, longitude: 30.313),
                              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                scale: 1
                              ))
                            ),
                            Placemark(
                              mapId: MapObjectId('placemark_3'),
                              point: Point(latitude: 39.956, longitude: 30.313),
                              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                scale: 1
                              ))
                            ),
                          ],
                          onTap: (ClusterizedPlacemarkCollection self, Point point) => print('Tapped me at $point'),
                        );

                        setState(() {
                          mapObjects.add(clusterizedPlacemarkCollection);
                        });
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

                        setState(() {
                          mapObjects[mapObjects.indexOf(clusterizedPlacemarkCollection)] =
                            clusterizedPlacemarkCollection.copyWith(placemarks: [
                              Placemark(
                                mapId: MapObjectId('placemark_2'),
                                point: Point(latitude: 59.956, longitude: 30.313),
                                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                  scale: 1
                                ))
                              ),
                              Placemark(
                                mapId: MapObjectId('placemark_3'),
                                point: Point(latitude: 39.956, longitude: 31.313),
                                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                  scale: 1
                                ))
                              ),
                              Placemark(
                                mapId: MapObjectId('placemark_4'),
                                point: Point(latitude: 59.945933, longitude: 30.320045),
                                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                  scale: 1
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
                          mapObjects.removeWhere((el) => el.mapId == clusterizedPlacemarkCollectionId);
                        });
                      },
                      title: 'Remove'
                    )
                  ],
                ),
                Text('Set of $kPlacemarkCount placemarks'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == largeClusterizedPlacemarkCollectionId)) {
                          return;
                        }

                        final clusterizedPlacemarkCollection = ClusterizedPlacemarkCollection(
                          mapId: largeClusterizedPlacemarkCollectionId,
                          radius: 30,
                          minZoom: 15,
                          onClusterAdded: (ClusterizedPlacemarkCollection self, Cluster cluster) async {
                            return cluster.copyWith(
                              appearance: cluster.appearance.copyWith(
                                opacity: 0.75,
                                icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromBytes(await _buildClusterAppearance(cluster)),
                                  scale: 1
                                ))
                              )
                            );
                          },
                          onClusterTap: (ClusterizedPlacemarkCollection self, Cluster cluster) {
                            print('Tapped cluster');
                          },
                          placemarks: List<Placemark>.generate(kPlacemarkCount, (i) {
                            return Placemark(
                              mapId: MapObjectId('placemark_$i'),
                              point: Point(latitude: 55.756 + _randomDouble(), longitude: 37.618 + _randomDouble()),
                              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                                scale: 1
                              ))
                            );
                          }),
                          onTap: (ClusterizedPlacemarkCollection self, Point point) => print('Tapped me at $point'),
                        );

                        setState(() {
                          mapObjects.add(clusterizedPlacemarkCollection);
                        });
                      },
                      title: 'Add'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == largeClusterizedPlacemarkCollectionId);
                        });
                      },
                      title: 'Remove'
                    )
                  ]
                )
              ]
            )
          )
        )
      ]
    );
  }
}
