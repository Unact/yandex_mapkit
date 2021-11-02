import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class ReverseSearchPage extends MapPage {
  const ReverseSearchPage() : super('Reverse search example');

  @override
  Widget build(BuildContext context) {
    return _ReverseSearchExample();
  }
}

class _ReverseSearchExample extends StatefulWidget {
  @override
  _ReverseSearchExampleState createState() => _ReverseSearchExampleState();
}

class _ReverseSearchExampleState extends State<_ReverseSearchExample> {
  final TextEditingController queryController = TextEditingController();
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  final MapObjectId cameraMapObjectId = MapObjectId('camera_placemark');

  @override
  Widget build(BuildContext context) {
    var mapHeight = 300.0;

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                YandexMap(
                  onMapCreated: (YandexMapController yandexMapController) async {
                    controller = yandexMapController;

                    final placemark = Placemark(
                      mapId: cameraMapObjectId,
                      point: Point(latitude: 55.755848, longitude: 37.620409),
                      style: PlacemarkStyle(
                        icon: PlacemarkIcon.fromIconName(
                          iconName: 'lib/assets/place.png',
                          style: PlacemarkIconStyle(scale: 0.75),
                        ),
                        opacity: 0.5,
                      )
                    );
                    mapObjects.add(placemark);

                    await controller.updateMapObjects(mapObjects);
                    await controller.move(cameraPosition: CameraPosition(target: placemark.point, zoom: 17));
                    await controller.enableCameraTracking(
                      onCameraPositionChange: (CameraPosition cameraPosition, bool finished) async {
                        final placemark = mapObjects.firstWhere((el) => el.mapId == cameraMapObjectId) as Placemark;
                        mapObjects[mapObjects.indexOf(placemark)] = placemark.copyWith(point: cameraPosition.target);

                        await controller.updateMapObjects(mapObjects);
                      }
                    );
                  },
                )
              ],
            ),
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
                        onPressed: _search,
                        title: 'What is here?'
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

  void _search() async {
    var point = await controller.getTargetPoint();

    print('Point: $point');

    var resultWithSession = YandexSearch.searchByPoint(
      point: point,
      zoom: 20,
      searchOptions: SearchOptions(
        searchType: SearchType.geo,
        geometry: false,
      ),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _SessionPage(point, resultWithSession.session, resultWithSession.result)
      )
    );
  }
}

class _SessionPage extends StatefulWidget {
  final Future<SearchSessionResult> result;
  final SearchSession session;
  final Point point;

  _SessionPage(this.point, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  final List<SearchSessionResult> results = [];
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
      appBar: AppBar(title: Text('Search ${widget.session.id}')),
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
                      await yandexMapController.move(cameraPosition: CameraPosition(target: widget.point, zoom: 17));
                      await yandexMapController.updateMapObjects([
                        Placemark(
                          mapId: MapObjectId('search_placemark'),
                          point: widget.point,
                          style: PlacemarkStyle(
                            icon: PlacemarkIcon.fromIconName(
                              iconName: 'lib/assets/place.png',
                              style: PlacemarkIconStyle(scale: 0.75),
                            ),
                          )
                        )
                      ]);
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
                          Text(
                            'Point',
                            style: TextStyle(fontSize: 20),
                          ),
                          !_progress ? Container() : TextButton.icon(
                            icon: const CircularProgressIndicator(),
                            label: const Text('Cancel'),
                            onPressed: _cancel
                          )
                        ],
                      )
                    ),
                    Row(children: [
                      Flexible(child:
                        Text('Lat: ${widget.point.latitude}, Lon: ${widget.point.longitude}')
                      )
                    ]),
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
      list.add(Text('Page: ${r.page}'));
      list.add(Container(height: 20));

      r.items!.asMap().forEach((i, item) {
        list.add(Text('Item $i: ${item.toponymMetadata!.formattedAddress}'));
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

  Future<void> _handleResult(SearchSessionResult result) async {
    setState(() { _progress = false; });

    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    print('Page ${result.page}: $result');

    setState(() { results.add(result); });

    if (await widget.session.hasNextPage()) {
      print('Got ${result.found} items, fetching next page...');
      setState(() { _progress = true; });
      await _handleResult(await widget.session.fetchNextPage());
    }
  }
}
