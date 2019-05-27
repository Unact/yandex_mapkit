import CoreLocation
import Flutter
import UIKit
import YandexMapKit

public class SwiftYandexMapkitPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel!
  static var controller: YandexMapController!
  static var pluginRegistrar: FlutterPluginRegistrar!

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "yandex_mapkit", binaryMessenger: registrar.messenger())

    registrar.addMethodCallDelegate(SwiftYandexMapkitPlugin(), channel: channel)
    registrar.register(
      YandexMapFactory(registrar: registrar),
      withId: "yandex_mapkit/yandex_map"
    )
  }

}
