part of yandex_mapkit;

typedef CameraPositionCallback = void Function(dynamic msg);
typedef SuggestSessionCallback = void Function(List<SuggestItem> msg);
typedef CancelSuggestCallback = void Function();
typedef ArgumentCallback<T> = void Function(T argument);
typedef MapCreatedCallback = void Function(YandexMapController controller);
