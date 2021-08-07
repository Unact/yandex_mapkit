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

  YandexMapController? controller;

  final List<SearchResponse> responseByPages = [];

  final Map<int,SearchSession> _sessions = {};

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
                    await controller!.move(point: Point(latitude: 55.755848, longitude: 37.620409), zoom: 17);
                  },
                ),
                Positioned(
                  bottom: mapHeight/2,
                  left: MediaQuery.of(context).size.width/2 - 16,
                  child: Image.asset('lib/assets/place.png', scale: 3),
                ),
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
                        onPressed: () async {
                          var targetPoint = await controller!.getTargetPoint();
                          search(targetPoint);
                        },
                        title: 'What is here?'
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Response:'),
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
    );
  }

  List<Widget> _getList() {

    var list = <Widget>[];

    for (var r in responseByPages) {

      list.add(Text('Page: ${r.page}'));
      list.add(Container(height: 20));

      r.items.asMap().forEach((i, item) {
        list.add(Text('Item $i: ${item.toponymMetadata!.formattedAddress}'));
      });

      list.add(Container(height: 20));
    }

    return list;
  }

  void search(Point point) async {

    print('Point: ${point.toString()}');

    responseByPages.clear();

    var sessionWithResponse = await YandexSearch.searchByPoint(
      point: point,
      zoom: 20,
      searchOptions: SearchOptions(
        searchType: SearchType.geo,
        geometry: false,
      ),
    );

    var session = sessionWithResponse.session;

    _sessions[session.id] = session;

    var responseOrError = await sessionWithResponse.responseOrError;

    await _handleResponse(session, responseOrError);

    print('No more results available, closing session...');
    await _closeSession(session);
  }

  Future<void> _closeSession(SearchSession session) async {

    await session.close();
    _sessions.remove(session.id);
  }

  Future<void> _handleResponse(SearchSession session, SearchResponseOrError responseOrError) async {

    if (responseOrError.error != null) {
      print('Error: ${responseOrError.error}');
      await _closeSession(session);
      return;
    }

    var response = responseOrError.response!;

    print('Page ${response.page}: ${response.toString()}');

    setState(() {
      responseByPages.add(response);
    });

    if (response.hasNextPage) {
      print('Got ${response.found} items, fetching next page...');
      await _handleResponse(session, await session.fetchNextPage());
    }
  }
}
