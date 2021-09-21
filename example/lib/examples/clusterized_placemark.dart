import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/data/dummy_image.dart' show rawImageData;
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class ClusterizedPlacemarkPage extends MapPage {
  const ClusterizedPlacemarkPage() : super('Clusterized placemark example');

  @override
  Widget build(BuildContext context) {
    return _ClusterizedPlacemarkExample();
  }
}

class _ClusterizedPlacemarkExample extends StatefulWidget {
  @override
  _ClusterizedPlacemarkExampleState createState() => _ClusterizedPlacemarkExampleState();
}

class _ClusterizedPlacemarkExampleState extends State<_ClusterizedPlacemarkExample> {
  YandexMapController? controller;
  ClusterizedPlacemarkCollection? clusterizedPlacemarkCollection;
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
                  await controller!.move(point: Point(latitude: 54.790246, longitude: 32.048847), zoom: 10.0);
                  // Create collection here!
                  clusterizedPlacemarkCollection = await controller!.addClusterizedPlacemarkCollection('lib/assets/user.png');
                  <dynamic>[
                    [54.790246, 32.048847],
                    [54.789960, 32.048933],
                    [54.789998, 32.050607],
                    [54.790072, 32.053096],
                    [54.788770, 32.054276],
                    [54.786203, 32.054426],
                    [54.791448, 32.047774],
                    [54.793147, 32.050821],
                  ].forEach((element) {
                      addPlacemark(Point(latitude: element[0], longitude:  element[1]));
                  });
                },
              )
          )
        ]
    );
  }

  Future<void> addPlacemark(Point point) async {
    await controller!.addClusterizedPlacemark(clusterizedPlacemarkCollection!, Placemark(
      point: point,
      style: const PlacemarkStyle(
        iconName: 'lib/assets/place.png',
        opacity: 0.9,
      ),
    ));
  }
}
