import CoreLocation
import Flutter
import UIKit
import YandexMapKit

public class YandexMapController: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel!
  private let emptyRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let viewController: UIViewController
  private let mapObjectCollectionListener = MapObjectCollectionListener()
  private let userLocationObjectListener: UserLocationObjectListener
  static var userLocationIconName: String!
  private var placemarks: [YMKPlacemarkMapObject] = []
  private let mapView: YMKMapView

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_ios",
      binaryMessenger: registrar.messenger()
    )
  }

  public required init(viewController: UIViewController, pluginRegistrar: FlutterPluginRegistrar) {
    self.viewController = viewController
    self.pluginRegistrar = pluginRegistrar
    self.userLocationObjectListener = UserLocationObjectListener(pluginRegistrar: pluginRegistrar)
    self.mapView = YMKMapView(frame: emptyRect)
    super.init()

    mapView.mapWindow.map!.mapObjects!.addListener(with: mapObjectCollectionListener)
    viewController.dismiss(animated: false)
    YandexMapController.register(with: pluginRegistrar)
    pluginRegistrar.addMethodCallDelegate(self, channel: YandexMapController.channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "showUserLayer":
      showUserLayer(call)
      result(nil)
    case "hideUserLayer":
      hideUserLayer()
      result(nil)
    case "hide":
      hide()
      result(nil)
    case "move":
      move(call)
      result(nil)
    case "reset":
      reset()
      result(nil)
    case "resize":
      resize(call)
      result(nil)
    case "show":
      show()
      result(nil)
    case "setBounds":
      setBounds(call)
      result(nil)
    case "addPlacemark":
      addPlacemark(call)
      result(nil)
    case "removePlacemark":
      removePlacemark(call)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func showUserLayer(_ call: FlutterMethodCall) {
    if (!hasLocationPermission()) { return }

    let params = call.arguments as! [String: Any]
    YandexMapController.userLocationIconName = params["iconName"] as! String

    let userLocationLayer = mapView.mapWindow.map!.userLocationLayer
    userLocationLayer!.isEnabled = true
    userLocationLayer!.isHeadingEnabled = true
    userLocationLayer!.setObjectListenerWith(userLocationObjectListener)
  }

  public func hideUserLayer() {
    if (!hasLocationPermission()) { return }

    let userLocationLayer = mapView.mapWindow.map!.userLocationLayer
    userLocationLayer!.isEnabled = false
  }

  public func hide() {
    mapView.removeFromSuperview()
  }

  public func move(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let point = YMKPoint(latitude: params["latitude"] as! Double, longitude: params["longitude"] as! Double)
    let cameraPosition = YMKCameraPosition(
      target: point,
      zoom: params["zoom"] as! Float,
      azimuth: params["azimuth"] as! Float,
      tilt: params["tilt"] as! Float
    )

    moveWithParams(params, cameraPosition)
  }

  public func resize(_ call: FlutterMethodCall) {
    mapView.frame = parseRect(call.arguments as! [String: Double])
  }

  public func reset() {
    hide()
    hideUserLayer()
    mapView.mapWindow.map!.mapObjects!.clear()
    placemarks.removeAll()
  }

  public func show() {
    viewController.view.addSubview(mapView)
  }

  public func setBounds(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let cameraPosition = mapView.mapWindow.map!.cameraPosition(with:
      YMKBoundingBox(
        southWest: YMKPoint(
          latitude: params["southWestLatitude"] as! Double,
          longitude: params["southWestLongitude"] as! Double
        ),
        northEast: YMKPoint(
          latitude: params["northEastLatitude"] as! Double,
          longitude: params["northEastLongitude"] as! Double
        )
      )
    )

    moveWithParams(params, cameraPosition)
  }

  public func addPlacemark(_ call: FlutterMethodCall) {
    addPlacemarkToMap(call.arguments as! [String: Any])
  }


  public func removePlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let mapObjects = mapView.mapWindow.map!.mapObjects!
    let placemark = placemarks.first(where: { $0.userData as! Int == params["hashCode"] as! Int })

    if (placemark != nil) {
      mapObjects.remove(with: placemark)
      placemarks.remove(at: placemarks.index(of: placemark!)!)
    }
  }

  private func addPlacemarkToMap(_ params: [String: Any]) {
    let point = YMKPoint(latitude: params["latitude"] as! Double, longitude: params["longitude"] as! Double)
    let mapObjects = mapView.mapWindow.map!.mapObjects!
    let placemark = mapObjects.addPlacemark(with: point)
    let iconName = params["iconName"] as? String

    placemark!.userData = params["hashCode"] as! Int
    placemark!.opacity = params["opacity"] as! Float
    placemark!.isDraggable = params["isDraggable"] as! Bool

    if (iconName != nil) {
      placemark!.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!)))
    }

    placemarks.append(placemark!)
  }

  private func moveWithParams(_ params: [String: Any], _ cameraPosition: YMKCameraPosition) {
    if (isMapViewEmptyRect()) { return }
    if (params["animate"] as! Bool) {
      let type = params["smoothAnimation"] as! Bool ? YMKAnimationType.smooth : YMKAnimationType.linear
      let animationType = YMKAnimation(type: type, duration: params["animationDuration"] as! Float)

      mapView.mapWindow.map!.move(with: cameraPosition, animationType: animationType)
    } else {
      mapView.mapWindow.map!.move(with: cameraPosition)
    }
  }

  private func parseRect(_ rect: [String: Double]) -> CGRect {
    return CGRect(x: rect["left"]!, y: rect["top"]!, width: rect["width"]!, height: rect["height"]!)
  }

  private func isMapViewEmptyRect() -> Bool {
    return mapView.frame.equalTo(emptyRect)
  }

  private func hasLocationPermission() -> Bool {
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied:
        return false
      case .authorizedAlways, .authorizedWhenInUse:
        return true
      }
    } else {
      return false
    }
  }

  internal class UserLocationObjectListener: NSObject, YMKUserLocationObjectListener {
    private let pluginRegistrar: FlutterPluginRegistrar!


    public required init(pluginRegistrar: FlutterPluginRegistrar) {
      self.pluginRegistrar = pluginRegistrar
    }

    func onObjectAdded(with view: YMKUserLocationView?) {
      view!.pin!.setIconWith(
        UIImage(named: pluginRegistrar.lookupKey(forAsset: YandexMapController.userLocationIconName!))
      )
    }

    func onObjectRemoved(with view: YMKUserLocationView?) {}

    func onObjectUpdated(with view: YMKUserLocationView?, event: YMKObjectEvent?) {}
  }

  internal class MapObjectCollectionListener: NSObject, YMKMapObjectCollectionListener {
    let mapObjectTapListener = MapObjectTapListener()
    internal class MapObjectTapListener: NSObject, YMKMapObjectTapListener {
      func onMapObjectTap(with mapObject: YMKMapObject?, point: YMKPoint) -> Bool {
        channel.invokeMethod("onMapObjectTap", arguments: [
          "hashCode": mapObject!.userData,
          "latitude": point.latitude,
          "longitude": point.longitude
        ])

        return true
      }
    }

    func onMapObjectAdded(with mapObject: YMKMapObject?) {
      mapObject?.addTapListener(with: mapObjectTapListener)
    }

    func onMapObjectRemoved(with mapObject: YMKMapObject?) {
      mapObject?.removeTapListener(with: mapObjectTapListener)
    }

    func onMapObjectUpdated(with mapObject: YMKMapObject?) {}
  }
}
