import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class SearchPage extends MapPage {
  const SearchPage() : super('Search example');

  @override
  Widget build(BuildContext context) {
    return _SearchExample();
  }
}

class _SearchExample extends StatefulWidget {
  @override
  _SearchExampleState createState() => _SearchExampleState();
}

class _SearchExampleState extends State<_SearchExample> {

  TextEditingController queryController = TextEditingController();

  final List<SearchResponse> responseByPages = [];

  final Map<int,SearchSession> _sessions = {};

  @override
  void dispose() async {

    super.dispose();

    for (var s in _sessions.values) {
      await s.close();
    }

    _sessions.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text('Search:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: queryController,
                      ),
                    ),
                    ControlButton(
                      onPressed: () {
                        search(queryController.text);
                      },
                      title: 'Query'
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

  void search(String query) async {

    print('Search query: $query');

    responseByPages.clear();

    var sessionWithResponse = await YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromBoundingBox(
        BoundingBox(
          southWest: Point(latitude: 55.76996383933034, longitude: 37.57483142322235),
          northEast: Point(latitude: 55.785322774728414, longitude: 37.590924677311705),
        )
      ),
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
