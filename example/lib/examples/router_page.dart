import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class RouterPage extends MapPage {
  const RouterPage() : super('Router example');

  @override
  Widget build(BuildContext context) {
    return _RouterExample();
  }
}

class _RouterExample extends StatefulWidget {
  @override
  _RouterExampleState createState() => _RouterExampleState();
}

class _RouterExampleState extends State<_RouterExample> {
  YandexMapController _controller;
  Polyline _route;
  bool _progress = false;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Expanded(child: YandexMap(
        onMapCreated: (YandexMapController yandexMapController) async {
          _controller = yandexMapController;
        },
      )),
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
                      setState(() {
                        _progress = true;
                      });
                      if (_route != null) {
                        await _controller.removePolyline(_route);
                      }
                      _route = await _buildRoute();
                      await _controller.addPolyline(_route);
                      setState(() {
                        _progress = false;
                      });
                    },
                    title: 'Build route',
                  ),
                  if (_progress) const CircularProgressIndicator(),
                  ControlButton(
                    onPressed: () async {
                      if (_route != null) {
                        await _controller.removePolyline(_route);
                      }
                    },
                    title: 'Remove',
                  )
                ],
              ),
            ],
          ),
        ),
      )
    ]);
  }

  Future<Polyline> _buildRoute() async {
    final routes = await YandexDrivingRouter.requestRoutes(
      [
        const RequestPoint(Point(latitude: 55.7558, longitude: 37.6173), RequestPointType.WAYPOINT),
        const RequestPoint(Point(latitude: 45.0360, longitude: 38.9746), RequestPointType.VIAPOINT),
        const RequestPoint(Point(latitude: 48.4814, longitude: 135.0721), RequestPointType.WAYPOINT),
      ],
    );

    return Polyline(
      coordinates: routes[0].geometry,
      style: const PolylineStyle(
        strokeColor: Colors.blueAccent,
        strokeWidth: 3, // <- default value 5.0, this will be a little bold
      ),
    );
  }
}
