import CoreLocation
import Flutter
import UIKit
import YandexMapsMobile

public class InitFull: InitLite {
  public override class func register(with registrar: FlutterPluginRegistrar) {
    super.register(with: registrar)

    YandexSearch.register(with: registrar)
    YandexSuggest.register(with: registrar)
    YandexDriving.register(with: registrar)
    YandexBicycle.register(with: registrar)
    YandexPedestrian.register(with: registrar)
  }
}
