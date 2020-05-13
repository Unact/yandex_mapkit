import 'dart:core';

import 'package:equatable/equatable.dart';

class SuggestItem extends Equatable{
  const SuggestItem({
    this.title,
    this.subtitle,
    this.searchText,
    this.type,
    this.tags
  });

  factory SuggestItem.fromJson(Map<String, dynamic> json) {
    return SuggestItem(
      title: json['title'],
      subtitle: json['subtitle'],
      searchText: json['searchText'],
      type: json['type'],
      tags: json['tags'],
    );
  }

  final String title;
  final String subtitle;
  final String searchText;
  final String type;
  final List<dynamic> tags;

  @override
  List<Object> get props => <Object>[
    title,
    subtitle,
    searchText,
    type,
    tags
  ];

  @override
  bool get stringify => true;
}
