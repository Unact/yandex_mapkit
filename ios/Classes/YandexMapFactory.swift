import Flutter
import UIKit
import YandexMapsMobile

public class YandexMapFactory: NSObject, FlutterPlatformViewFactory {
  private let pluginRegistrar: FlutterPluginRegistrar!

  public init(registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    super.init()
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  public func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return YandexMapController(
      id: viewId,
      frame: frame,
      registrar: self.pluginRegistrar,
      params: args as! [String: Any]
    )
  }
}
