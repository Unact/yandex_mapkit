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
      await s.closeSearchSession();
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

    var session = await YandexSearch.searchByText(
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

    _sessions[session.id] = session;

    // Listen to results stream
    session.results.listen((res) {

      var resStr = res.toString();

      print('Page ${res.page}: $resStr');

      setState(() {
        responseByPages.add(res);
      });

      if (res.hasNextPage) {
        print('Got ${res.found} items, fetching next page...');
        session.fetchSearchNextPage();
      } else {
        print('No more results available, closing session...');
        session.closeSearchSession();
        _sessions.remove(session.id);
      }

    }, onError: (error) {
      if (error is PlatformException) {
        print('Error: ${error.message}');
      }
    });

    // Uncomment to check cancellation
    // print('Cancel search');
    // await session.cancelSearch();
  }
}
