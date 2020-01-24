import 'dart:core';

class SuggestItem {
  SuggestItem(
      {this.title, this.subtitle, this.searchText, this.type, this.tags});

  factory SuggestItem.fromJson(Map<String, dynamic> json) {
    return SuggestItem(
      title: json['title'],
      subtitle: json['subtitle'],
      searchText: json['searchText'],
      type: json['type'],
      tags: json['tags'],
    );
  }

  String title;
  String subtitle;
  String searchText;
  String type;
  List<dynamic> tags;
}
