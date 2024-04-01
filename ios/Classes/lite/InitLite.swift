import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class InitLite: Init {
  public class func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(
      YandexMapFactory(registrar: registrar),
      withId: "yandex_mapkit/yandex_map"
    )

    YMKMapKit.sharedInstance().onStart()
  }
}
