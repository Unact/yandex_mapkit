import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() async {
  await YandexMapkit.setup(apiKey: 'YOUR_API_KEY');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<YandexMapViewState> _mapKey = GlobalKey<YandexMapViewState>();
  static Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  YandexMap _yandexMap = YandexMapkit().yandexMap;
  Placemark _placemark = Placemark(
    point: _point,
    iconName: 'lib/assets/place.png',
    onTap: (latitude, longitude) => print('Tapped me at $latitude,$longitude')
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('YandexMapkit Plugin')
        ),
        body: Column(
          children: [
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.show();
                  },
                  child: Text('Show')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.hide();
                  },
                  child: Text('Hide')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.move(
                      point: _point,
                      animation: MapAnimation(smooth: true, duration: 2.0)
                    );
                  },
                  child: Text('Move')
                ),
              ]
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.addPlacemark(_placemark);
                  },
                  child: Text('Add placemark')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.removePlacemark(_placemark);
                  },
                  child: Text('Remove placemark')
                ),
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.setBounds(
                      southWestPoint: Point(latitude: 60.0, longitude: 30.0),
                      northEastPoint: Point(latitude: 65.0, longitude: 40.0),
                    );
                  },
                  child: Text('setBounds')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.resize(Rect.fromLTWH(200.0, 200.0, 100.0, 100.0));
                  },
                  child: Text('Resize')
                )
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.showUserLayer(iconName: 'lib/assets/user.png');
                  },
                  child: Text('Show User')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMap.hideUserLayer();
                  },
                  child: Text('Hide User')
                )
              ],
            ),
            Expanded(
              child: YandexMapView(
                key: _mapKey,
                afterMapRefresh: () async {
                  await _mapKey.currentState.yandexMap.removePlacemark(_placemark);
                  await _mapKey.currentState.yandexMap.addPlacemark(_placemark);
                },
              )
            )
          ]
        ),
      )
    );
  }
}
