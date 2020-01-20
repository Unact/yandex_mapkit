import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/page.dart';

class SearchPage extends Page {
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
  YandexMapController controller;
  TextEditingController queryController = TextEditingController();
  String response = '';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: YandexMap(
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;
              controller.onSuggestCallback = suggestionsCallback;
            },
          )
        ),
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
                    RaisedButton(
                      onPressed: () {
                        querySuggestions(queryController.text);
                      },
                      child: const Text('Query')
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Response:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(response)
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

  void suggestionsCallback(List<SuggestItem> suggestItems) {
    setState(() {
      response = '';
      for (SuggestItem item in suggestItems) {
        response += item.title + '\n';
      }
    });
  }

  void querySuggestions(String query) {
    controller.getSuggestions(const Point(latitude: 55.5143, longitude: 37.24841), const Point(latitude: 56.0421, longitude: 38.0284), query, 'GEO', true);
  }
}
