## 0.3.9

* Update and lock YandexMapkit version to 3.5 for iOS and Android
* Fix example not working on newer flutter versions

## 0.3.8

* Add support for comparing objects added by YandexMapkit[#46, Goolpe]

## 0.3.7

* Add Polygon support [#36, umcherrel]
* Add Placemark options [#36, umcherrel]
* Add user location options [#36, umcherrel]
* Implement MapkitSearch [#36, umcherrel]
* Add camera tracing [#36, umcherrel]

## 0.3.6

* Set minimum flutter version to 1.10.0
* Update iOS and Android dependencies
* Fix YandexMap not compiling on iOS
* Fix YandexMap not showing when `onMapCreated` is not defined [#38, DCrow]
* Minor fixes

## 0.3.5

* Add Polyline support [#33, elisar4]
* Add support for using binary image as Placemark icons [#30, elisar4]
* Refactor example app [#31, DCrow]

## 0.3.4

* Add getting target point(center point) [#27, Ishokov-Dzhafar]

## 0.3.3

* Add linter and fix linter errors[#23, vanyasem]
* Add location permission request messages to example app[#23, vanyasem]
* Update and lock YandexMapkit version to 3.4 for iOS and Android[#23, vanyasem]
* Update .gitignore[#25, DCrow]
* Fix typos in README[#23, vanyasem]

## 0.3.2

* Add styling functionality [#18, vanyasem]

## 0.3.1

* Fix `YandexMapController.addPlacemark` sometimes not working on iOS [#13, Ishokov-Dzhafar]
* Remove unused code

## 0.3.0

* **Breaking change**. Changed iOS and Android Mapkit key initialization

## 0.2.1

* Add zoom functionality [#10, Ishokov-Dzhafar]

## 0.2.0

* **Breaking change**. Migrate from the deprecated original Android Support Library to AndroidX.

## 0.1.3+2

* Fix some of pub.dartlang.com suggestions
* Fix Xcode 10.1 SWIFT_VERSION error

## 0.1.3+1

* Lock YandexRuntime to 3.2 (https://github.com/Unact/yandex_mapkit/issues/3)

## 0.1.3

* Bump YandexMapkit version to 3.2 for ios and android

## 0.1.2

* Change ios implementation to use `UiKitView`
* Change `AnroidView.gestureRecognizers` to accept all gestures
* Change method signature `Future<Null>` to `Future<void>`

## 0.1.1

* Bugfixes

## 0.1.0

* Change android implementation to use `AndroidView`
* Change ios implementation to match android

## 0.0.2

* Add functionality to show/hide current user location

## 0.0.1

* Initial release
