part of yandex_mapkit;

class ObjectsCollection {

  final int   id;
  final bool  isClusterized;
  final int?  parentId;

  ObjectsCollection({
    this.isClusterized = false,
    this.parentId,
  }) : id = UniqueKey().hashCode;

  Map<String, dynamic> toJson() {

    var json = <String, dynamic>{
      'id': id,
      'isClusterized': isClusterized,
    };

    if (parentId != null) {
      json['parentId'] = parentId!;
    }

    return json;
  }
}
