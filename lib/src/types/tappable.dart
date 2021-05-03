part of yandex_mapkit;

abstract class Tappable extends WithKey {

  TapCallback<Tappable, Point>? get onTap => null;

}