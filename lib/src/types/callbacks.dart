part of yandex_mapkit;

typedef CameraPositionCallback = void Function(dynamic msg);
typedef SuggestSessionCallback = void Function(List<SuggestItem> msg);
typedef CancelSuggestCallback = void Function();
typedef GenericCallback = void Function();
typedef ArgumentCallback<T> = void Function(T argument);
typedef TapCallback<T, S> = void Function(T point, S tapReceiver);
typedef MapCreatedCallback = void Function(YandexMapController controller);
typedef SearchErrorCallback = void Function(String msg, int sessionId);
typedef CancelDrivingSessionCallback = void Function();
