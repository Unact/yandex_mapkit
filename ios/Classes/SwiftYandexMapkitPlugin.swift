import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class SwiftYandexMapkitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(
      YandexMapFactory(registrar: registrar),
      withId: "yandex_mapkit/yandex_map"
    )

    YMKMapKit.sharedInstance().onStart()

    YandexSearch.register(with: registrar)
    YandexSuggest.register(with: registrar)
    YandexDriving.register(with: registrar)
    YandexBicycle.register(with: registrar)
  }
}
