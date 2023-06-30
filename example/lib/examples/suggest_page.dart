import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class SuggestionsPage extends MapPage {
  const SuggestionsPage({Key? key}) : super('Suggest example', key: key);

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
                        decoration: const InputDecoration(hintText: 'Address part'),
                      ),
                    ),
                    ControlButton(
                      onPressed: _suggest,
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

  Future<void> _suggest() async {
    final query = queryController.text;

    print('Suggest query: $query');

    final resultWithSession = YandexSuggest.getSuggestions(
      text: query,
      boundingBox: const BoundingBox(
        northEast: Point(latitude: 56.0421, longitude: 38.0284),
        southWest: Point(latitude: 55.5143, longitude: 37.24841)
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
        suggestWords: true,
        userPosition: Point(latitude: 56.0321, longitude: 38)
      )
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
  final Future<SuggestSessionResult> result;
  final SuggestSession session;
  final String query;

  const _SessionPage(this.query, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  final List<SuggestSessionResult> results = [];
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
      appBar: AppBar(title: Text('Suggest ${widget.session.id}')),
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
                            label: const Text('Reset'),
                            onPressed: _reset
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
      r.items!.asMap().forEach((i, item) {
        list.add(Text('Item $i: ${item.title}'));
      });
    }

    return list;
  }

  Future<void> _reset() async {
    await widget.session.reset();

    setState(() { _progress = false; });
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(SuggestSessionResult result) async {
    setState(() { _progress = false; });

    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    setState(() { results.add(result); });
  }
}
