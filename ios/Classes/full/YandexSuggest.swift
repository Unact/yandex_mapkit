import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class YandexSuggest: NSObject, FlutterPlugin {
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let methodChannel: FlutterMethodChannel!
  private let searchManager: YMKSearchManager!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_suggest",
      binaryMessenger: registrar.messenger()
    )

    let plugin = YandexSuggest(channel: channel, registrar: registrar)

    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public required init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.methodChannel = channel
    self.searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)

    super.init()

    self.methodChannel.setMethodCallHandler(self.handle)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initSession":
      initSession(call)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func initSession(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let id  = params["id"] as! Int

    YandexSuggestSession.initSession(id: id, registrar: pluginRegistrar, searchManager: searchManager)
  }
}
