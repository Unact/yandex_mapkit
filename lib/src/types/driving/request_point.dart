part of yandex_mapkit;

class RequestPoint extends Equatable {
  final Point point;
  final RequestPointType requestPointType;

  const RequestPoint({
    required this.point,
    required this.requestPointType
  });

  @override
  List<Object> get props => <Object>[
    point,
    requestPointType,
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'requestPointType': requestPointType.value,
      'point': point.toJson()
    };
  }
}

enum RequestPointType { wayPoint, viaPoint }

extension RequestPointTypeExtension on RequestPointType {
  int get value {
    switch (this) {
      case RequestPointType.wayPoint:
        return 0;
      case RequestPointType.viaPoint:
        return 1;
    }
  }
}
