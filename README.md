# yandex_mapkit

A flutter plugin for displaying yandex maps on iOS and Android. Now fully integrated with flutters widget tree.

__Disclaimer__: This project uses Yandex Mapkit which belongs to Yandex  
When using Mapkit refer to these [terms of use](https://tech.yandex.com/maps/doc/mapkit/3.x/concepts/conditions-docpage/)

## Getting Started

### Generate your API Key

1. Go to https://developer.tech.yandex.com
2. Create a `MapKit mobile SDK` key

### Initializing for iOS

1. Add `import YandexMapKit` to `ios/Runner/AppDelegate.swift`
2. Add `YMKMapKit.setApiKey("YOUR_API_KEY")` inside `func application` in `ios/Runner/AppDelegate.swift`
3. Specify your API key in the application delegate `ios/Runner/AppDelegate.swift`
4. Add `<key>io.flutter.embedded_views_preview</key> <true/>` inside `<dict>` tag in `ios/Runner/Info.plist`
5. Uncomment `platform :ios, '9.0'` in `ios/Podfile`

`ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import YandexMapKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    YMKMapKit.setApiKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
```

### Initializing for Android

1. Add dependency `implementation 'com.yandex.android:mapkit:3.4.0'` and `implementation 'com.yandex.android:search:3.4.0'` to `android/app/build.gradle`
2. Add permissions `uses-permission android:name="android.permission.INTERNET` and `uses-permission android:name="android.permission.ACCESS_FINE_LOCATION` to `android/app/src/main/AndroidManifest.xml`
3. Add `import com.yandex.mapkit.MapKitFactory;` to `android/app/src/main/.../MainActivity.java`
4. Add `MapKitFactory.setApiKey("YOUR_API_KEY");` inside method `onCreate` in `android/app/src/main/.../MainActivity.java`
5. Specify your API key in the application delegate `android/app/src/main/.../MainActivity.java`


`android/app/build.gradle`:

```groovy
dependencies {
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'androidx.test:runner:1.1.1'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.1.1'
    implementation 'com.yandex.android:mapkit:3.4.0'
    implementation 'com.yandex.android:search:3.4.0'
}
```

`android/app/src/main/.../MainActivity.java`:

#### Flutter versions prior to 1.12

```java
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.yandex.mapkit.MapKitFactory;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MapKitFactory.setApiKey("YOUR_API_KEY");
    GeneratedPluginRegistrant.registerWith(this);
  }
}
```

#### Flutter versions after and including 1.12

```java
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    MapKitFactory.setApiKey("YOUR_API_KEY");
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }
}
```

### Usage

Example:

```dart
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() async {
  runApp(MyApp());
}
```

You can use a `YandexMap` which resizes itself to its parent size

```dart
Expanded(child: YandexMap())
```

For usage examples refer to example app

### Features

- [X] iOS Support
- [X] Android Support
- [X] Adding and removing Placemarks
- [X] Receive Placemark tap events
- [X] Moving around the map
- [X] Setting map bounds
- [X] Showing current user location
- [X] Styling the map
- [X] Adding and removing Polylines
- [X] Adding and removing Polygons
- [X] Address suggestion
