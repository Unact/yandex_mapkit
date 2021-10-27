part of yandex_mapkit;

typedef CameraPositionCallback = void Function(CameraPosition cameraPosition, bool finished);
typedef SuggestSessionCallback = void Function(List<SuggestItem> msg);
typedef CancelSuggestCallback = void Function();
typedef GenericCallback = void Function();
typedef ArgumentCallback<T> = void Function(T argument);
typedef TapCallback<T> = void Function(T mapObject, Point point);
typedef ClusterCallback = Cluster? Function(ClusterizedPlacemarkCollection, Cluster);
typedef ClusterTapCallback = void Function(ClusterizedPlacemarkCollection, Cluster);
typedef MapCreatedCallback = void Function(YandexMapController controller);
typedef MapRenderedCallback = void Function(YandexMapController controller, MapSize size);
typedef SearchErrorCallback = void Function(String msg, int sessionId);
typedef CancelDrivingSessionCallback = void Function();
