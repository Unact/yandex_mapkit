import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class SuggestionsPage extends MapPage {
  const SuggestionsPage() : super('Suggestions example');

  @override
  Widget build(BuildContext context) {
    return _SuggestionsExample();
  }
}

class _SuggestionsExample extends StatefulWidget {
  @override
  _SuggestionsExampleState createState() => _SuggestionsExampleState();
}

class _SuggestionsExampleState extends State<_SuggestionsExample> {
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
                        querySuggestions(queryController.text);
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

  Future<void> querySuggestions(String query) async {
    final cancelListening = await YandexSearch.getSuggestions(
      address: query,
      southWestPoint: const Point(latitude: 55.5143, longitude: 37.24841),
      northEastPoint: const Point(latitude: 56.0421, longitude: 38.0284),
      suggestType: SuggestType.geo,
      suggestWords: true,
      onSuggest: (List<SuggestItem> suggestItems) {
        setState(() {
          response = suggestItems.map((SuggestItem item) => item.title).join('\n');
        });
      }
    );
    await Future<dynamic>.delayed(const Duration(seconds: 3), () => cancelListening());
  }
}
