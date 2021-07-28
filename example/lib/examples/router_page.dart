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
  late YandexMapController _controller;
  late DrivingSession _session;
  Polyline? _route;
  bool _progress = false;
  String? _error;

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
                            await _controller.removePolyline(_route!);
                          }
                          _session = await _buildRoutes();
                          setState(() {
                            _progress = true;
                          });
                          await _parseSession();
                          setState(() {
                            _progress = false;
                          });
                        },
                        title: 'Build route',
                      ),
                      _progressWidget(),
                      ControlButton(
                        onPressed: () async {
                          if (_route != null) {
                            await _controller.removePolyline(_route!);
                          }
                        },
                        title: 'Remove route',
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ]);
  }

  Future<void> _parseSession() async {
    final result = await _session.result;
    final routes = result.routes;
    if (routes != null) {
      _route = Polyline(
        coordinates: routes[0].geometry,
        style: const PolylineStyle(
          strokeColor: Colors.blueAccent,
          strokeWidth: 3,
        ),
      );
      await _controller.addPolyline(_route!);
    }
    _error = result.error;
  }

  Widget _progressWidget() {
    if (_progress) {
      return TextButton.icon(
        icon: const CircularProgressIndicator(),
        label: const Text('Cancel'),
        onPressed: () {
          _session.cancelSession();
          setState(() {
            _progress = false;
          });
        },
      );
    } else if (_error != null) {
      return Text('Error: $_error', style: TextStyle(color: Colors.red));
    } else {
      return const Spacer(flex: 1);
    }
  }
}

Future<DrivingSession> _buildRoutes() async {
  return await YandexDrivingRouter.requestRoutes(
    <RequestPoint>[
      const RequestPoint(Point(latitude: 55.7558, longitude: 37.6173),
          RequestPointType.wayPoint),
      const RequestPoint(Point(latitude: 45.0360, longitude: 38.9746),
          RequestPointType.viaPoint),
      const RequestPoint(Point(latitude: 48.4814, longitude: 135.0721),
          RequestPointType.wayPoint),
    ],
  );
}
