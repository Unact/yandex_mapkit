# yandex_mapkit

A flutter plugin for displaying yandex maps on iOS and Android.

|             | Android |   iOS   |
|-------------|---------|---------|
| __Support__ | SDK 21+ | iOS 12+ |

__Disclaimer__: This project uses Yandex Mapkit which belongs to Yandex  
When using Mapkit refer to these [terms of use](https://yandex.com/dev/mapkit/doc/en/conditions)

## Getting Started

### Generate your API Key

1. Go to https://developer.tech.yandex.ru/services/
2. Create a `MapKit Mobile SDK` key

### Initializing for iOS

1. Add `import YandexMapsMobile` to `ios/Runner/AppDelegate.swift`
2. Add `YMKMapKit.setApiKey("YOUR_API_KEY")` inside `func application`
   in `ios/Runner/AppDelegate.swift`
3. Specify your API key in the application delegate `ios/Runner/AppDelegate.swift`
4. Uncomment `platform :ios, '9.0'` in `ios/Podfile` and change to `platform :ios, '12.0'`

`ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import YandexMapsMobile

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    YMKMapKit.setLocale("YOUR_LOCALE") // Your preferred language. Not required, defaults to system language
    YMKMapKit.setApiKey("YOUR_API_KEY") // Your generated API key
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Initializing for Android

1. Add dependency `implementation 'com.yandex.android:maps.mobile:4.3.2-full'`
   to `android/app/build.gradle`
2. Add permissions `<uses-permission android:name="android.permission.INTERNET"/>`
   and `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`
   to `android/app/src/main/AndroidManifest.xml`
3. Add `import com.yandex.mapkit.MapKitFactory;` to `android/app/src/main/.../MainActivity.java`
   /`android/app/src/main/.../MainActivity.kt`
4. `MapKitFactory.setApiKey("YOUR_API_KEY");` inside method `onCreate`
   in `android/app/src/main/.../MainActivity.java`/`android/app/src/main/.../MainActivity.kt`
5. Specify your API key in the application delegate `android/app/src/main/.../MainActivity.java`
   /`android/app/src/main/.../MainActivity.kt`

`android/app/build.gradle`:

```groovy
dependencies {
    implementation 'com.yandex.android:maps.mobile:4.3.2-full'
}
```

#### For Java projects

`android/app/src/main/.../MainActivity.java`:

```java
import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.yandex.mapkit.MapKitFactory;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        MapKitFactory.setLocale("YOUR_LOCALE"); // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("YOUR_API_KEY"); // Your generated API key
        super.configureFlutterEngine(flutterEngine);
    }
}
```

#### For Kotlin projects

`android/app/src/main/.../MainActivity.kt`

```kotlin
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.yandex.mapkit.MapKitFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setLocale("YOUR_LOCALE") // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("YOUR_API_KEY") // Your generated API key
        super.configureFlutterEngine(flutterEngine)
    }
}
```

### Usage

For usage examples refer to
example [app](https://github.com/Unact/yandex_mapkit/tree/master/example)

![image](https://user-images.githubusercontent.com/8961745/100362969-26e23880-300d-11eb-9529-6ab36beffa51.png)

### Additional remarks

YandexMapkit always works with __one language__ only.  
Due to native constraints after the application is launched it can't be changed.

#### Android

##### Hybrid Composition

By default android views are rendered
using [Hybrid Composition](https://flutter.dev/docs/development/platform-integration/platform-views)
.
To render the `YandexMap` widget on Android using Virtual Display(old composition), set
AndroidYandexMap.useAndroidViewSurface to false.
Place this anywhere in your code, before using `YandexMap` widget.

```dart
AndroidYandexMap.useAndroidViewSurface = false;
```

### Features

- [X] Working with Placemarks/Polylines/Polygons/Circles - adding, updating, removing, tap events,
  styling
- [X] Working with collections of map objects
- [X] Working with clusters
- [X] Moving around the map
- [X] Setting map bounds
- [X] Showing current user location
- [X] Styling the map
- [X] Address suggestions
- [X] Basic driving/bicycle/pedestrian routing
- [X] Basic address direct/reverse search
- [X] Working with geo objects
- [X] Showing current traffic conditions
