import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class TrafficLayerPage extends MapPage {
  const TrafficLayerPage({Key? key}) : super('Traffic layer example', key: key);

  @override
  Widget build(BuildContext context) {
    return _TrafficLayerExample();
  }
}

class _TrafficLayerExample extends StatefulWidget {
  @override
  _TrafficLayerExampleState createState() => _TrafficLayerExampleState();
}

class _TrafficLayerExampleState extends State<_TrafficLayerExample> {
  late YandexMapController controller;

  int level = 0;
  Color trafficColor = Colors.white;

  Color _colorFromTraffic(TrafficColor trafficColor) {
    switch (trafficColor) {
      case TrafficColor.red:
        return Colors.red;
      case TrafficColor.yellow:
        return Colors.yellow;
      case TrafficColor.green:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: [
              YandexMap(
                onMapCreated: (YandexMapController yandexMapController) async {
                  controller = yandexMapController;
                },
                onTrafficChanged: (TrafficLevel? trafficLevel) {
                  setState(() {
                    level = trafficLevel?.level ?? 0;
                    trafficColor = trafficLevel != null ? _colorFromTraffic(trafficLevel.color) : Colors.white;
                  });
                }
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: trafficColor),
                    child: Center(child: Text(level.toString()))
                  ),
                ),
              )
            ]
          )
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
                      onPressed: () async {
                        await controller.toggleTrafficLayer(visible: true);
                      },
                      title:'Show traffic layer'
                    ),
                    ControlButton(
                      onPressed: () async {
                        await controller.toggleTrafficLayer(visible: false);
                      },
                      title:'Hide traffic layer'
                    )
                  ],
                )
              ]
            )
          )
        )
      ]
    );
  }
}
