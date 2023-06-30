import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class SearchPage extends MapPage {
  const SearchPage({Key? key}) : super('Search example', key: key);

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
  final TextEditingController queryController = TextEditingController();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: queryController,
                        decoration: const InputDecoration(hintText: 'Search'),
                      ),
                    ),
                    ControlButton(
                      onPressed: _search,
                      title: 'Query'
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

  void _search() async {
    final query = queryController.text;

    print('Search query: $query');

    final resultWithSession = YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromBoundingBox(
        const BoundingBox(
          southWest: Point(latitude: 55.76996383933034, longitude: 37.57483142322235),
          northEast: Point(latitude: 55.785322774728414, longitude: 37.590924677311705),
        )
      ),
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
        geometry: false,
      ),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _SessionPage(query, resultWithSession.session, resultWithSession.result)
      )
    );
  }
}

class _SessionPage extends StatefulWidget {
  final Future<SearchSessionResult> result;
  final SearchSession session;
  final String query;

  const _SessionPage(this.query, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  final List<SearchSessionResult> results = [];
  bool _progress = true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();

    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search ${widget.session.id}')),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.query, style: const TextStyle(fontSize: 20,)),
                          !_progress ? Container() : TextButton.icon(
                            icon: const CircularProgressIndicator(),
                            label: const Text('Cancel'),
                            onPressed: _cancel
                          )
                        ],
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
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
        )
      )
    );
  }

  List<Widget> _getList() {
    final list = <Widget>[];

    if (results.isEmpty) {
      list.add((const Text('Nothing found')));
    }

    for (var r in results) {
      list.add(Text('Page: ${r.page}'));
      list.add(Container(height: 20));

      r.items!.asMap().forEach((i, item) {
        list.add(Text('Item $i: ${item.toponymMetadata!.address.formattedAddress}'));
      });

      list.add(Container(height: 20));
    }

    return list;
  }

  Future<void> _cancel() async {
    await widget.session.cancel();

    setState(() { _progress = false; });
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(SearchSessionResult result) async {
    setState(() { _progress = false; });

    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    print('Page ${result.page}: $result');

    setState(() { results.add(result); });

    if (await widget.session.hasNextPage()) {
      print('Got ${result.found} items, fetching next page...');
      setState(() { _progress = true; });
      await _handleResult(await widget.session.fetchNextPage());
    }
  }
}
