# yandex_mapkit

A flutter plugin for displaying yandex maps on iOS and Android.

__Disclaimer__: This project uses Yandex Mapkit which belongs to Yandex  
When using Mapkit refer to these [terms of use](https://tech.yandex.com/maps/doc/mapkit/3.x/concepts/conditions-docpage/)

## Getting Started

### Generate your API Key

1. Go to https://developer.tech.yandex.com
2. Create a `MapKit mobile SDK` key

### Initializing for iOS

1. Add `import YandexMapsMobile` to `ios/Runner/AppDelegate.swift`
2. Add `YMKMapKit.setApiKey("YOUR_API_KEY")` inside `func application` in `ios/Runner/AppDelegate.swift`
3. Specify your API key in the application delegate `ios/Runner/AppDelegate.swift`
4. For Flutter version less than 1.22 add `<key>io.flutter.embedded_views_preview</key> <true/>` inside `<dict>` tag in `ios/Runner/Info.plist`
5. Uncomment `platform :ios, '9.0'` in `ios/Podfile`

`ios/Runner/AppDelegate.swift`:

For Swift 4.0 and lesser

```swift
import UIKit
import Flutter
import YandexMapsMobile

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    YMKMapKit.setLocale("YOUR_LOCALE") // Your preferred language. Not required, defaults to system language
    YMKMapKit.setApiKey("YOUR_API_KEY") // Your generated API key
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

For Swift 4.2 and greater

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

1. Add dependency `implementation 'com.yandex.android:maps.mobile:4.0.0-full'` to `android/app/build.gradle`
2. Add permissions `<uses-permission android:name="android.permission.INTERNET"/>` and `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>` to `android/app/src/main/AndroidManifest.xml`
3. Add `import com.yandex.mapkit.MapKitFactory;` to `android/app/src/main/.../MainActivity.java`/`android/app/src/main/.../MainActivity.kt`
4. `MapKitFactory.setApiKey("YOUR_API_KEY");` inside method `onCreate` in `android/app/src/main/.../MainActivity.java`/`android/app/src/main/.../MainActivity.kt`
5. Specify your API key in the application delegate `android/app/src/main/.../MainActivity.java`/`android/app/src/main/.../MainActivity.kt`

`android/app/build.gradle`:

```groovy
dependencies {
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'androidx.test:runner:1.1.1'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.1.1'
    implementation 'com.yandex.android:maps.mobile:4.0.0-full'
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

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    MapKitFactory.setLocale("YOUR_LOCALE") // Your preferred language. Not required, defaults to system language
    MapKitFactory.setApiKey("YOUR_API_KEY") // Your generated API key
    super.configureFlutterEngine(flutterEngine)
  }
}
```

### Usage

For usage examples refer to example [app](https://github.com/Unact/yandex_mapkit/tree/master/example)

![image](https://user-images.githubusercontent.com/8961745/100362969-26e23880-300d-11eb-9529-6ab36beffa51.png)

### Additional remarks

This project only supports Android V2 embedding. V1 support has been completly dropped.
If you are creating a new flutter project then you are automatically using V2 and don't have to worry.
Other projects are strongly recommended to migrate to V2. See [this](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects) page for more details.

YandexMapkit always works with __one language__ only.  
Due to native constraints after the application is launched it can't be changed.

#### iOS

Currently native library doesn't support Silicon Mac.  
If you receive this type of error

```text
ld: in /.../ios/Pods/YandexMapsMobile/YandexMapsMobile.framework/YandexMapsMobile(YMKRouteView_Binding.mm.o), building for iOS Simulator, but linking in object file built for iOS, file '/.../ios/Pods/YandexMapsMobile/YandexMapsMobile.framework/YandexMapsMobile' for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

Add in your projects `Build Settings` in section `Excluded Architectures` for `Debug` this line - `arm64`  
This way XCode won't try to build for Silicon Macs iOS Simulators

### Features

- [X] iOS Support
- [X] Android Support
- [X] Working with Placemarks/Polylines/Polygons/Circles - adding, updating, removing, tap events, styling
- [X] Working with collections of map objects
- [X] Moving around the map
- [X] Setting map bounds
- [X] Showing current user location
- [X] Styling the map
- [X] Address suggestions
- [X] Basic driving routing
- [X] Basic address direct/reverse search
