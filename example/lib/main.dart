import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  Placemark _placemark = Placemark(
    point: _point,
    iconName: 'lib/assets/Mark.png',
    onTap: (latitude, longitude) => print('Tapped me at $latitude,$longitude')
  );
  YandexMapkit _yandexMapkit = YandexMapkit();

  Rect _buildRect(BuildContext context) {
    RenderObject object = _scaffoldKey.currentContext.findRenderObject();
    Vector3 translation = object.getTransformTo(null).getTranslation();
    Size size = object.semanticBounds.size;

    return Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
  }

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
                    await _yandexMapkit.map.showFitRect(_buildRect(context));
                  },
                  child: Text('Show')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapkit.map.hide();
                  },
                  child: Text('Hide')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapkit.map.move(
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
                    await _yandexMapkit.map.addPlacemark(_placemark);
                  },
                  child: Text('Add placemark')
                ),
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapkit.map.removePlacemark(_placemark);
                  },
                  child: Text('Remove placemark')
                ),
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    await _yandexMapkit.map.setBounds(
                      southWestPoint: Point(latitude: 60.0, longitude: 30.0),
                      northEastPoint: Point(latitude: 65.0, longitude: 40.0),
                    );
                  },
                  child: Text('setBounds')
                ),
                RaisedButton(
                  onPressed: () async {
                    Rect rect = _buildRect(context);
                    Rect newRect = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height + 100.0);
                    await _yandexMapkit.map.resize(newRect);
                  },
                  child: Text('Resize')
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: SizedBox(
                key: _scaffoldKey,
                width: 300.0,
                height: 300.0
              )
            )
          ]
        ),
      )
    );
  }
}
