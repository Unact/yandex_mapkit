import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class ReverseSearchPage extends MapPage {
  const ReverseSearchPage({Key? key}) : super('Reverse search example', key: key);

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
  late final List<MapObject> mapObjects = [
    PlacemarkMapObject(
      mapId: cameraMapObjectId,
      point: const Point(latitude: 55.755848, longitude: 37.620409),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
          scale: 0.75
        )
      ),
      opacity: 0.5,
    )
  ];

  final MapObjectId cameraMapObjectId = const MapObjectId('camera_placemark');

  @override
  Widget build(BuildContext context) {
    const mapHeight = 300.0;

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
                  mapObjects: mapObjects,
                  onCameraPositionChanged: (CameraPosition cameraPosition, CameraUpdateReason _, bool __) async {
                    final placemarkMapObject = mapObjects
                      .firstWhere((el) => el.mapId == cameraMapObjectId) as PlacemarkMapObject;

                    setState(() {
                      mapObjects[mapObjects.indexOf(placemarkMapObject)] = placemarkMapObject.copyWith(
                        point: cameraPosition.target
                      );
                    });
                  },
                  onMapCreated: (YandexMapController yandexMapController) async {
                    final placemarkMapObject = mapObjects
                      .firstWhere((el) => el.mapId == cameraMapObjectId) as PlacemarkMapObject;

                    controller = yandexMapController;

                    await controller.moveCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(target: placemarkMapObject.point, zoom: 17))
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
    final cameraPosition = await controller.getCameraPosition();

    print('Point: ${cameraPosition.target}, Zoom: ${cameraPosition.zoom}');

    final resultWithSession = YandexSearch.searchByPoint(
      point: cameraPosition.target,
      zoom: cameraPosition.zoom.toInt(),
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
        geometry: false,
      ),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _SessionPage(
          cameraPosition.target,
          resultWithSession.session,
          resultWithSession.result
        )
      )
    );
  }
}

class _SessionPage extends StatefulWidget {
  final Future<SearchSessionResult> result;
  final SearchSession session;
  final Point point;

  const _SessionPage(this.point, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  final List<MapObject> mapObjects = [];

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
                    mapObjects: mapObjects,
                    onMapCreated: (YandexMapController yandexMapController) async {
                      final placemarkMapObject = PlacemarkMapObject(
                        mapId: const MapObjectId('search_placemark'),
                        point: widget.point,
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage('lib/assets/place.png'),
                            scale: 0.75
                          )
                        )
                      );

                      setState(() {
                        mapObjects.add(placemarkMapObject);
                      });

                      await yandexMapController.moveCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(target: widget.point, zoom: 17))
                      );
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
                          const Text(
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
                            padding: const EdgeInsets.only(top: 20),
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
    final list = <Widget>[];

    if (results.isEmpty) {
      list.add((const Text('Nothing found')));
    }

    for (var r in results) {
      list.add(Text('Page: ${r.page}'));
      list.add(Container(height: 20));

      r.items!.asMap().forEach((i, item) {
        list.add(Text('Item $i: ${item.toponymMetadata!.address.formattedAddress}'));
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
