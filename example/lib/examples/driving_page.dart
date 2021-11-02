import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class DrivingPage extends MapPage {
  const DrivingPage() : super('Driving example');

  @override
  Widget build(BuildContext context) {
    return _DrivingExample();
  }
}

class _DrivingExample extends StatefulWidget {
  @override
  _DrivingExampleState createState() => _DrivingExampleState();
}

class _DrivingExampleState extends State<_DrivingExample> {
  final Placemark startPlacemark = Placemark(
    mapId: MapObjectId('start_placemark'),
    point: Point(latitude: 55.7558, longitude: 37.6173),
    style: PlacemarkStyle(
      icon: PlacemarkIcon.fromIconName(
        iconName: 'lib/assets/route_start.png',
        style: PlacemarkIconStyle(scale: 0.3),
      ),
    ),
  );
  final Placemark stopByPlacemark = Placemark(
    mapId: MapObjectId('stop_by_placemark'),
    point: Point(latitude: 45.0360, longitude: 38.9746),
    style: PlacemarkStyle(
      icon: PlacemarkIcon.fromIconName(
        iconName: 'lib/assets/route_stop_by.png',
        style: PlacemarkIconStyle(scale: 0.3),
      ),
    ),
  );
  final Placemark endPlacemark = Placemark(
    mapId: MapObjectId('end_placemark'),
    point: Point(latitude: 48.4814, longitude: 135.0721),
    style: PlacemarkStyle(
      icon: PlacemarkIcon.fromIconName(
        iconName: 'lib/assets/route_end.png',
        style: PlacemarkIconStyle(scale: 0.3),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: YandexMap(
          onMapCreated: (YandexMapController yandexMapController) async {
            final placemarks = [
              startPlacemark,
              stopByPlacemark,
              endPlacemark
            ];

            await yandexMapController.updateMapObjects(placemarks);
          },
        )),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ControlButton(
                  onPressed: _requestRoutes,
                  title: 'Build route',
                ),
              ]
            )
          )
        )
      ]
    );
  }

  Future<void> _requestRoutes() async {
    print('Points: ${startPlacemark.point},${stopByPlacemark.point},${endPlacemark.point}');

    var resultWithSession = YandexDriving.requestRoutes(points: [
      RequestPoint(point: startPlacemark.point, requestPointType: RequestPointType.wayPoint),
      RequestPoint(point: stopByPlacemark.point, requestPointType: RequestPointType.viaPoint),
      RequestPoint(point: endPlacemark.point, requestPointType: RequestPointType.wayPoint),
    ]);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _SessionPage(
          startPlacemark,
          endPlacemark,
          resultWithSession.session,
          resultWithSession.result
        )
      )
    );
  }
}


class _SessionPage extends StatefulWidget {
  final Future<DrivingSessionResult> result;
  final DrivingSession session;
  final Placemark startPlacemark;
  final Placemark endPlacemark;

  _SessionPage(this.startPlacemark, this.endPlacemark, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  final List<DrivingSessionResult> results = [];
  bool _progress = true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();

    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driving ${widget.session.id}')),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  YandexMap(
                    onMapCreated: (YandexMapController yandexMapController) async {
                      controller = yandexMapController;
                      mapObjects.addAll([widget.startPlacemark, widget.endPlacemark]);

                      await controller.updateMapObjects(mapObjects);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          !_progress ? Container() : TextButton.icon(
                            icon: const CircularProgressIndicator(),
                            label: const Text('Cancel'),
                            onPressed: _cancel
                          )
                        ],
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _getList(),
                            )
                          ),
                        ),
                      ],
                    ),
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  List<Widget> _getList() {
    var list = <Widget>[];

    if (results.isEmpty) {
      list.add((Text('Nothing found')));
    }

    for (var r in results) {
      list.add(Container(height: 20));

      r.routes!.asMap().forEach((i, route) {
        list.add(Text('Route $i: ${route.metadata.weight.timeWithTraffic.text}'));
      });

      list.add(Container(height: 20));
    }

    return list;
  }

  Future<void> _cancel() async {
    await widget.session.cancel();

    setState(() { _progress = false; });
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(DrivingSessionResult result) async {
    setState(() { _progress = false; });

    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    setState(() { results.add(result); });

    result.routes!.asMap().forEach((i, route) {
      mapObjects.add(Polyline(
        mapId: MapObjectId('route_${i}_polyline'),
        coordinates: route.geometry,
        style: PolylineStyle(
          strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          strokeWidth: 3,
        ),
      ));
    });

    await controller.updateMapObjects(mapObjects);
  }
}
