import CoreLocation
import Flutter
import UIKit

public class SwiftYandexMapkitPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(
      YandexMapFactory(registrar: registrar),
      withId: "yandex_mapkit/yandex_map"
    )
    
    YandexSearch.register(with: registrar)
  }

}
