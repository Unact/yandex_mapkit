import 'package:flutter/material.dart';

abstract class MapPage extends StatelessWidget {
  const MapPage(this.title, { Key? key }) : super(key: key);

  final String title;
}
