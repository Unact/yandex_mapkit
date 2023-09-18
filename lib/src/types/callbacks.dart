part of yandex_mapkit;

typedef CameraPositionCallback = void Function(
    CameraPosition cameraPosition, CameraUpdateReason reason, bool finished);
typedef ArgumentCallback<T> = void Function(T argument);
typedef TapCallback<T> = void Function(T mapObject, Point point);
typedef DragStartCallback<T> = void Function(T mapObject);
typedef DragCallback<T> = void Function(T mapObject, Point point);
typedef DragEndCallback<T> = void Function(T mapObject);
typedef ClusterCallback = Future<Cluster?> Function(
    ClusterizedPlacemarkCollection self, Cluster cluster);
typedef ClusterTapCallback = void Function(
    ClusterizedPlacemarkCollection self, Cluster cluster);
typedef MapCreatedCallback = void Function(YandexMapController controller);
typedef UserLocationCallback = Future<UserLocationView>? Function(
    UserLocationView view);
typedef TrafficChangedCallback = void Function(TrafficLevel? trafficLevel);
typedef ObjectTapCallback = void Function(GeoObject geoObject);
