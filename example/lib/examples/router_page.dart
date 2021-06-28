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
  DrivingSession _result;
  bool _progress = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                          if (_route != null) {
                            await _controller.removePolyline(_route);
                          }
                          _result = await _buildRoutes();
                          setState(() {
                            _progress = true;
                          });
                          _route = await _polyline(_result);
                          await _controller.addPolyline(_route);
                          setState(() {
                            _progress = false;
                          });
                        },
                        title: 'Build route',
                      ),
                      progressWidget(),
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

  Widget progressWidget() {
    return _progress
        ? TextButton.icon(
            icon: const CircularProgressIndicator(),
            label: const Text('Cancel'),
            onPressed: () {
              _result.cancelSession();
              setState(() {
                _progress = false;
              });
            },
          )
        : const Spacer(flex: 1);
  }

  Future<Polyline> _polyline(DrivingSession result) async {
    final List<DrivingRoute> routes = await result.routes;

    return Polyline(
      coordinates: routes[0].geometry,
      style: const PolylineStyle(
        strokeColor: Colors.blueAccent,
        strokeWidth: 3, // <- default value 5.0, this will be a little bold
      ),
    );
  }

  Future<DrivingSession> _buildRoutes() async {
    return await YandexDrivingRouter.requestRoutes(
      <RequestPoint>[
        const RequestPoint(Point(latitude: 55.7558, longitude: 37.6173),
            RequestPointType.WAYPOINT),
        const RequestPoint(Point(latitude: 45.0360, longitude: 38.9746),
            RequestPointType.VIAPOINT),
        const RequestPoint(Point(latitude: 48.4814, longitude: 135.0721),
            RequestPointType.WAYPOINT),
      ],
    );
  }
}
