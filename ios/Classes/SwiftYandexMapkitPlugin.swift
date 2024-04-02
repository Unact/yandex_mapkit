import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class SwiftYandexMapkitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if YANDEX_MAPKIT_LITE
    InitLite.register(with: registrar)
    #endif

    #if YANDEX_MAPKIT_FULL
    InitFull.register(with: registrar)
    #endif
  }
}
