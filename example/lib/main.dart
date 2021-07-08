import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';
import 'package:yandex_mapkit_example/examples/camera_tracking_page.dart';
import 'package:yandex_mapkit_example/examples/circle_page.dart';
import 'package:yandex_mapkit_example/examples/layers_page.dart';
import 'package:yandex_mapkit_example/examples/map_controls_page.dart';
import 'package:yandex_mapkit_example/examples/placemark_page.dart';
import 'package:yandex_mapkit_example/examples/polyline_page.dart';
import 'package:yandex_mapkit_example/examples/polygon_page.dart';
import 'package:yandex_mapkit_example/examples/rotation_page.dart';
import 'package:yandex_mapkit_example/examples/search_page.dart';
import 'package:yandex_mapkit_example/examples/suggestions_page.dart';

void main() {
  runApp(MaterialApp(home: MainPage()));
}

const List<MapPage> _allPages = <MapPage>[
  CameraTrackingPage(),
  LayersPage(),
  MapControlsPage(),
  PlacemarkPage(),
  PolylinePage(),
  PolygonPage(),
  CirclePage(),
  RotationPage(),
  SuggestionsPage(),
  SearchPage(),
];

class MainPage extends StatelessWidget {
  void _pushPage(BuildContext context, MapPage page) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) =>
        Scaffold(
          appBar: AppBar(title: Text(page.title)),
          body: Container(
            padding: const EdgeInsets.all(8),
            child: page
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YandexMap examples')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const YandexMap()
            )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allPages.length,
              itemBuilder: (_, int index) => ListTile(
                title: Text(_allPages[index].title),
                onTap: () => _pushPage(context, _allPages[index]),
              ),
            )
          )
        ]
      )
    );
  }
}
