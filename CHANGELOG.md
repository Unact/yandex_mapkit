## 2.0.6

* Fix iOS crash for `YandexMapController.moveCamera`
* Add the ability to follow user
* Fixed mutable lists in `Polygon`, `Polyline`
* **Breaking change**. Removed const definition from `Polygon`, `Polyline`, `Circle`, `Placemark`

## 2.0.5

* Fix several crashes for iOS and Android

## 2.0.4

* Minor optimizations
* Fix incorrect displaying of clusters for slow devices
* Fix Android init on Activity restart in example app
* Fix incorrect rendering of UserLocationView MapObjects

## 2.0.3

* Fix iOS crash for `YandexSuggest.getSuggestions`
* Fix incorrect PlacemarkIconStyle constructor signature

## 2.0.2

* Fix Android view showing when `AndroidYandexMap.useAndroidViewSurface = true` and MainActivity is FlutterFragmentActivity

## 2.0.1

* Fix Android view showing when `AndroidYandexMap.useAndroidViewSurface = true` [#180, just-kip]
* Fix incorrect results for `YandexMapController.getVisibleRegion` and `YandexMapController.getFocusRegion`

## 2.0.0

* Add Hybrid composition for Android
* Implement `YandexDriving`
* Implement `YandexSearch`, move suggest functionality to `YandexSuggest`
* Added the ability to add composite icon Placemark
* Added the ability to work with MapObjectCollection
* Added the ability to control which tap events should be consumed
* Added placemark clusterization
* Added visibility toogle for all map objects
* Added draggablity toggle for `Placemark`.
* Allow specifing which gestures should be intercepted by `YandexMap`
* Add `YandexMapController.getFocusRegion` to get visible region with focusRect taken into account
* Add `YandexMapController.getPoint`/`YandexMapController.getScreenPoint` for working with screen/map coordinates
* **Breaking change**. Removed `MapAnimation.smooth`. Replaced with `MapAnimation.type`.
* **Breaking change**. Removed `YandexMapController.onMapSizeChanged`
* **Breaking change**. Remove `PlacemarkStyle`, `CircleStyle`, `PolygonStyle`, `PolylineStyle`.
All styling options can now be directly set on corresponding map objects.
* **Breaking change**. Removed rawImageData/iconName options from `Placemark`. Use `PlacemarkIconStyle.image` instead.
* **Breaking change**. Removed
 `YandexMapController.move`,
 `YandexMapController.setBounds`,
 `YandexMapController.zoomOut`,
 `YandexMapController.zoomIn`.
  Use universal `YandexMapController.moveCamera` instead.
* **Breaking change**. Move and change method signature `YandexSearch.getSuggestions` to `YandexSuggest.getSuggestions`
* **Breaking change**. Rework working with map objects. Removed
 `YandexMapController.addPlacemark`, `YandexMapController.removePlacemark`,
 `YandexMapController.addPolygon`, `YandexMapController.removePolygon`,
 `YandexMapController.addPolyline`, `YandexMapController.removePolyline`,
 `YandexMapController.addCircle`, `YandexMapController.removeCircle`.
Use `YandexMap.mapObjects` in conjuction with `setState` to add and remove map objects.
* **Breaking change**. `YandexMapController.setFocusRect` and `YandexMapController.clearFocusRect` moved to
 `YandexMap.focusRect` property.
* **Breaking change**. `YandexMapController.logoAlignment` moved to `YandexMap.logoAlignment` property.
* **Breaking change**. `YandexMapController.move` method signature has been changed.
* **Breaking change**. `YandexMapController.setBounds` method signature has been changed.
* **Breaking change**. `YandexMapController.setFocusRect` method signature has been changed.
* **Breaking change**. `YandexMapController.getVisibleRegion` method signature has been changed.
* **Breaking change**. `YandexMapController.setMapStyle` method signature has been changed.
* **Breaking change**. Removed `YandexMapController.getZoom`, `YandexMapController.getTargetPoint`.
Use `YandexMapController.getCameraPosition` to get zoom, target and much more.
* **Breaking change**. Removed `YandexMapController.getUserTargetPoint`
Use `YandexMapController.getUserCameraPosition` to get target and much more.
* **Breaking change**. Removed `YandexMapController.enableCameraTracking`/`YandexMapController.disableCameraTracking`
Use `YandexMap.onCameraPositionChanged` to receive camera updates
* **Breaking change**. Removed `YandexMapController.toggleMapRotation`. Use `YandexMap.rotateGesturesEnabled` instead.
* **Breaking change**. Removed `YandexMapController.toggleTiltGestures` and `YandexMapController.isTiltGesturesEnabled`.
Use `YandexMap.tiltGesturesEnabled` instead.
* **Breaking change**. Removed `YandexMapController.toggleNightMode`. Use `YandexMap.nightModeEnabled` instead.
* **Breaking change**. Removed `YandexMapController.toggleZoomGestures` and `YandexMapController.isZoomGesturesEnabled`.
Use `YandexMap.zoomGesturesEnabled` instead.
* **Breaking change**. `YandexSuggest.getSuggestions` method signature has been changed.

## 1.1.1

* Fix compiling errors for swift versions lower than 5.4 [#119, cream-cheeze]

## 1.1.0

* Add gesture manipulation [#120, cream-cheeze]
* Add additional zoom features(min/max, disabling/enabling) [#116, cream-cheeze]
* Add the ability to work with `Circle` objects [#115, cream-cheeze]

## 1.0.1

* Fix memory leak on iOS #107

## 1.0.0

* Migrate to null-safety
* Add the ability to create `Polygon` with different inner shapes.
* Add the ability to get users current point
* Add the ability to set focus rectangle
* **Breaking change**. Removed `YandexMapController.moveToUser`.
* **Breaking change**. `YandexSearch.getSuggestions` method signature has been drastically changed.
* **Breaking change**. `Placemark.onTap` callback signature has been changed. Now also returns `Placemark` on which this callback has been called.
* **Breaking change**. `YandexMapController.enableCameraTracking` method signature has been changed.

## 0.5.1

* Add visible region retrieval for `YandexMapController`

## 0.5.0

* Update and lock YandexMapkit version to 4.0.0-full for iOS and Android
* Add `onMapRendered` and `onMapSizeChanged` callbacks to `YandexMap`
* **Breaking change**. `YandexMapController.enableCameraTracking` now uses `PlacemarkStyle` instead of `Placemark` for styling tracking marker.
* **Breaking change**. `Placemark`, `Polyline`, `Polygon` constructors have been changed.
Styling now requires an instance of `PlacemarkStyle`/`PolylineStyle`/`PolygonStyle`.

## 0.4.2

* Add support for changing yandex logo position [#79, Goolpe]

## 0.4.1

* Add Placemark direction and rotationType [#68, ryufitreet]
* Add Map rotation toggle [#68, ryufitreet]

## 0.4.0

* Add support for v2 android embedder
* Add night mode toggle for `YandexMapController`
* Add `onMapTap` and `onMapLongTap` callbacks to `YandexMap`
* **Breaking change**. Callback signature for `Placemark.onTap` has been changed.
Instead of returning latitude and longitude, it now returns a `Point`

## 0.3.11

* Fix memory leak on iOS

## 0.3.10

* Fix Dart int, bool, double, float data conversion in Swift

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
