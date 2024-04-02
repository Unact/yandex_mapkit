# yandex_mapkit

A flutter plugin for displaying yandex maps on iOS and Android.

|             | Android |   iOS   |
|-------------|---------|---------|
| __Support__ | SDK 21+ | iOS 12+ |

__Disclaimer__: This project uses Yandex Mapkit which belongs to Yandex  
When using Mapkit refer to these [terms of use](https://yandex.com/dev/mapkit/doc/en/conditions)

## Features

* [X] Working with Placemarks/Polylines/Polygons/Circles - adding, updating, removing, tap events, styling
* [X] Working with collections of map objects and clusters
* [X] Setting map bounds and limiting user interactions
* [X] Showing current user location
* [X] Address suggestions
* [X] Basic driving/bicycle/pedestrian routing
* [X] Basic address direct/reverse search
* [X] Working with geo objects
* [X] Support for both lite and full variants 

## Getting Started

### Generate your API Key

1. Go to https://developer.tech.yandex.ru/services/
2. Create a `MapKit Mobile SDK` key

### Setup for iOS

* Specify your API key and locale in `ios/Runner/AppDelegate.swift`. It should be similar to the following

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

* Uncomment `platform :ios, '9.0'` in `ios/Podfile` and change to `platform :ios, '12.0'`

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'
```

* Specify your desired variant of native library.  
Available options: `lite` and `full`. `navikit` variant is currently not supported.  
Defaults to `lite`.  

Include the following line right after `ENV['COCOAPODS_DISABLE_STATS'] = 'true'`

```ruby
ENV['YANDEX_MAPKIT_VARIANT'] = '<YOUR_DESIRED_VARIANT>'
```

### Setup for Android

* Specify your desired variant of native library.  
Available options: `lite` and `full`. `navikit` variant is currently not supported.  
Defaults to `lite`.  

Add the following line to `android/gradle.properties`

```groovy
yandexMapkit.variant=<YOUR_DESIRED_VARIANT>
```

* Add dependency `implementation 'com.yandex.android:maps.mobile:4.5.1-<YOUR_DESIRED_VARIANT>'` to `android/app/build.gradle`

```groovy
dependencies {
    implementation 'com.yandex.android:maps.mobile:4.5.1-<YOUR_DESIRED_VARIANT>'
}
```

* Specify your API key and locale in your custom application class.  
If you don't have one the you can create it like so

`android/app/src/main/.../MainApplication.java`

```java
import android.app.Application;

import com.yandex.mapkit.MapKitFactory;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        MapKitFactory.setLocale("YOUR_LOCALE"); // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("YOUR_API_KEY"); // Your generated API key
    }
}
```

`android/app/src/main/.../MainApplication.kt`

```kotlin
import android.app.Application

import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setLocale("YOUR_LOCALE") // Your preferred language. Not required, defaults to system language
    MapKitFactory.setApiKey("YOUR_API_KEY") // Your generated API key
  }
}
```

* In your `android/app/src/main/AndroidManifest.xml`

Add permissions `<uses-permission android:name="android.permission.INTERNET"/>` and `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`

Find `application` tag and replace `android:name` to the name of your custom application class prefixed by a dot `.`.
In the end it should look like the following

```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <application
      android:name=".MainApplication" >
```

### Usage

For usage examples refer to example [app](https://github.com/Unact/yandex_mapkit/tree/master/example)

![image](https://github.com/Unact/yandex_mapkit/assets/8961745/eba23fa6-1381-4a3f-98cd-47d3346a767b)

### Additional remarks

#### Language

YandexMapkit always works with __one language__ only.  
Due to native constraints after the application is launched it can't be changed.

#### Android. Hybrid Composition

By default android views are rendered using [Hybrid Composition](https://flutter.dev/docs/development/platform-integration/platform-views).  
To render the `YandexMap` widget on Android using Virtual Display(old composition), set AndroidYandexMap.useAndroidViewSurface to false.  
Place this anywhere in your code, before using `YandexMap` widget.  

```dart
AndroidYandexMap.useAndroidViewSurface = false;
```

