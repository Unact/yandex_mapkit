import 'dart:async';

import 'package:flutter/material.dart';
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

  String response = '';

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
                                  child: Text(response),
                                )
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

  Future<void> search(String query) async {

    await YandexSearch.searchByText(
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
      onSearchResponse: (SearchResponse res) {
        setState(() {
          response = res.toString();
        });
      },
      onSearchError: (String error) {
        print(error);
      });
  }
}
