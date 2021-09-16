part of yandex_mapkit;

class RequestPoint extends Equatable {
  final Point point;
  final RequestPointType requestPointType;

  const RequestPoint(this.point, this.requestPointType);

  @override
  List<Object> get props => <Object>[
    point,
    requestPointType,
  ];

  @override
  bool get stringify => true;
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
