import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class MapControlsPage extends MapPage {
  const MapControlsPage() : super('Map controls example');

  @override
  Widget build(BuildContext context) {
    return _MapControlsExample();
  }
}

class _MapControlsExample extends StatefulWidget {
  @override
  _MapControlsExampleState createState() => _MapControlsExampleState();
}

class _MapControlsExampleState extends State<_MapControlsExample> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  final MapObjectId targetMapObjectId = MapObjectId('target_placemark');
  static const Point _point = Point(latitude: 59.945933, longitude: 30.320045);
  final animation = const MapAnimation(type: MapAnimationType.smooth, duration: 2.0);

  bool tiltGesturesEnabled = true;
  bool zoomGesturesEnabled = true;
  bool rotateGesturesEnabled = true;
  bool scrollGesturesEnabled = true;
  bool modelsEnabled = true;
  bool nightModeEnabled = false;
  bool fastTapEnabled = false;
  bool mode2DEnabled = false;
  bool indoorEnabled = false;
  bool liteModeEnabled = false;
  ScreenRect? screenRect;

  final String style = '''
    [
      {
        "tags": {
          "all": ["landscape"]
        },
        "stylers": {
          "color": "f00",
          "saturation": 0.5,
          "lightness": 0.5
        }
      }
    ]
  ''';

  String _enabledText(bool enabled) {
    return enabled ? 'on' : 'off';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: YandexMap(
            tiltGesturesEnabled: tiltGesturesEnabled,
            zoomGesturesEnabled: zoomGesturesEnabled,
            rotateGesturesEnabled: rotateGesturesEnabled,
            scrollGesturesEnabled: scrollGesturesEnabled,
            modelsEnabled: modelsEnabled,
            nightModeEnabled: nightModeEnabled,
            fastTapEnabled: fastTapEnabled,
            mode2DEnabled: mode2DEnabled,
            indoorEnabled: indoorEnabled,
            liteModeEnabled: liteModeEnabled,
            logoAlignment: MapAlignment(horizontal: HorizontalAlignment.left, vertical: VerticalAlignment.bottom),
            screenRect: screenRect,
            mapObjects: mapObjects,
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;

              final cameraPosition = await controller.getCameraPosition();
              final minZoom = await controller.getMinZoom();
              final maxZoom = await controller.getMaxZoom();

              print('Camera position: $cameraPosition');
              print('Min zoom: $minZoom, Max zoom: $maxZoom');
            },
            onMapTap: (Point point) => print('Tapped map at $point'),
            onMapLongTap: (Point point) => print('Long tapped map at $point'),
            onCameraPositionChanged: (CameraPosition cameraPosition, CameraUpdateReason reason, bool finished) {
              print('Camera position: $cameraPosition, Reason: $reason');

              if (finished) {
                print('Camera position movement has been finished');
              }
            },
          )
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              children: <TableRow>[
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      await controller.moveCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(target: _point)),
                        animation: animation
                      );
                    },
                    title: 'Specific position'
                  ),
                  ControlButton(
                    onPressed: () async {
                      await controller.moveCamera(CameraUpdate.zoomTo(1), animation: animation);
                    },
                    title: 'Specific zoom'
                  )
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      await controller.moveCamera(CameraUpdate.azimuthTo(1), animation: animation);
                    },
                    title: 'Specific azimuth'
                  ),
                  ControlButton(
                    onPressed: () async {
                      await controller.moveCamera(CameraUpdate.tiltTo(1), animation: animation);
                    },
                    title: 'Specific tilt'
                  ),
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      await controller.moveCamera(CameraUpdate.zoomIn(), animation: animation);
                    },
                    title: 'Zoom in'
                  ),
                  ControlButton(
                    onPressed: () async {
                      await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);
                    },
                    title: 'Zoom out'
                  ),
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      final newBounds = BoundingBox(
                        northEast: const Point(latitude: 65.0, longitude: 40.0),
                        southWest: const Point(latitude: 60.0, longitude: 30.0),
                      );
                      await controller.moveCamera(CameraUpdate.newBounds(newBounds), animation: animation);
                    },
                    title: 'New bounds'
                  ),
                  ControlButton(
                    onPressed: () async {
                      final newBounds = BoundingBox(
                        northEast: const Point(latitude: 65.0, longitude: 40.0),
                        southWest: const Point(latitude: 60.0, longitude: 30.0),
                      );
                      await controller.moveCamera(
                        CameraUpdate.newTiltAzimuthBounds(newBounds, azimuth: 1, tilt: 1),
                        animation: animation
                      );
                    },
                    title: 'New bounds with tilt and azimuth'
                  ),
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      final placemark = Placemark(
                        mapId: targetMapObjectId,
                        point: (await controller.getCameraPosition()).target,
                        opacity: 0.7,
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage('lib/assets/place.png')
                          )
                        )
                      );

                      setState(() {
                        mapObjects.removeWhere((el) => el.mapId == targetMapObjectId);
                        mapObjects.add(placemark);
                      });
                    },
                    title: 'Target point'
                  ),
                  Container()
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      await controller.setMapStyle(style);
                    },
                    title: 'Set Style'
                  ),
                  ControlButton(
                    onPressed: () async {
                      await controller.setMapStyle('');
                    },
                    title: 'Remove style'
                  ),
                ]),
                TableRow(
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        final cameraPosition = await controller.getCameraPosition();
                        final screenPoint = await controller.getScreenPoint(cameraPosition.target);

                        setState(() {
                          screenRect = ScreenRect(
                            topLeft: ScreenPoint(x: 0, y: 0),
                            bottomRight: screenPoint!
                          );
                        });
                      },
                      title: 'Focus rect'
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          screenRect = null;
                        });
                      },
                      title: 'Clear focus rect'
                    )
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        final region = await controller.getFocusRegion();
                        print(region);
                      },
                      title: 'Focus region'
                    ),
                    ControlButton(
                      onPressed: () async {
                        final region = await controller.getVisibleRegion();
                        print(region);
                      },
                      title: 'Visible region'
                    )
                  ],
                ),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      final screenPoint = await controller.getScreenPoint(
                        (await controller.getCameraPosition()).target
                      );

                      print(screenPoint);
                    },
                    title: 'Map point to screen'
                  ),
                  ControlButton(
                    onPressed: () async {
                      final mediaQuery = MediaQuery.of(context);
                      final point = await controller.getPoint(
                        ScreenPoint(x: mediaQuery.size.width, y: mediaQuery.size.height)
                      );

                      print(point);
                    },
                    title: 'Screen point to map'
                  ),
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                      onPressed: () async {
                        setState(() {
                          tiltGesturesEnabled = !tiltGesturesEnabled;
                        });
                      },
                      title: 'Tilt gestures: ${_enabledText(tiltGesturesEnabled)}'
                  ),
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        rotateGesturesEnabled = !rotateGesturesEnabled;
                      });
                    },
                    title: 'Rotate gestures: ${_enabledText(rotateGesturesEnabled)}'
                  ),
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        zoomGesturesEnabled = !zoomGesturesEnabled;
                      });
                    },
                    title: 'Zoom gestures: ${_enabledText(zoomGesturesEnabled)}'
                  ),
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        scrollGesturesEnabled = !scrollGesturesEnabled;
                      });
                    },
                    title: 'Scroll gestures: ${_enabledText(scrollGesturesEnabled)}'
                  )
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        modelsEnabled = !modelsEnabled;
                      });
                    },
                    title: 'Models: ${_enabledText(modelsEnabled)}'
                  ),
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        nightModeEnabled = !nightModeEnabled;
                      });
                    },
                    title: 'Night mode: ${_enabledText(nightModeEnabled)}'
                  )
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        fastTapEnabled = !fastTapEnabled;
                      });
                    },
                    title: 'Fast tap: ${_enabledText(fastTapEnabled)}'
                  ),
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        mode2DEnabled = !mode2DEnabled;
                      });
                    },
                    title: '2D mode: ${_enabledText(mode2DEnabled)}'
                  )
                ]),
                TableRow(children: <Widget>[
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        indoorEnabled = !indoorEnabled;
                      });
                    },
                    title: 'Indoor mode: ${_enabledText(indoorEnabled)}'
                  ),
                  ControlButton(
                    onPressed: () async {
                      setState(() {
                        liteModeEnabled = !liteModeEnabled;
                      });
                    },
                    title: 'Lite mode: ${_enabledText(liteModeEnabled)}'
                  )
                ])
              ],
            ),
          ),
        )
      ]
    );
  }
}
