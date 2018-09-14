import Flutter
import UIKit
import YandexMapKit

public class SwiftYandexMapkitPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let viewController: UIViewController
  private let mapObjectCollectionListener = MapObjectCollectionListener()
  private var placemarks: [YMKPlacemarkMapObject] = []
  private var mapView: YMKMapView?

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "yandex_mapkit", binaryMessenger: registrar.messenger())
    let appDelegate = UIApplication.shared.delegate!
    let viewController = appDelegate.window?!.rootViewController
    let instance = SwiftYandexMapkitPlugin(viewController: viewController!, pluginRegistrar: registrar)
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public required init(viewController: UIViewController, pluginRegistrar: FlutterPluginRegistrar) {
    self.viewController = viewController
    self.pluginRegistrar = pluginRegistrar
    viewController.dismiss(animated: false)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setApiKey":
      setApiKey(call)
      result(nil)
    case "create":
      mapView == nil ? create(call) : nil
      result(nil)
    case "destroy":
      mapView != nil ? destroy(call) : nil
      result(nil)
    case "hide":
      mapView != nil ? hide(call) : nil
      result(nil)
    case "move":
      mapView != nil ? move(call) : nil
      result(nil)
    case "resize":
      mapView != nil ? resize(call) : nil
      result(nil)
    case "show":
      mapView != nil ? show(call) : nil
      result(nil)
    case "setBounds":
      mapView != nil ? setBounds(call) : nil
      result(nil)
    case "addPlacemark":
      mapView != nil ? addPlacemark(call) : nil
      result(nil)
    case "removePlacemark":
      mapView != nil ? removePlacemark(call) : nil
      result(nil)
    case "removePlacemarks":
      mapView != nil ? removePlacemarks(call) : nil
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func setApiKey(_ call: FlutterMethodCall) {
    YMKMapKit.setApiKey(call.arguments as! String?)
  }
  
  private func create(_ call: FlutterMethodCall) {
    mapView = YMKMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    mapView!.mapWindow.map!.mapObjects!.addListener(with: mapObjectCollectionListener)
  }
  
  private func destroy(_ call: FlutterMethodCall) {
    mapView = nil
  }
  
  private func hide(_ call: FlutterMethodCall) {
    mapView!.removeFromSuperview()
  }
  
  private func move(_ call: FlutterMethodCall) {
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
  
  private func resize(_ call: FlutterMethodCall) {
    mapView?.frame = parseRect(call.arguments as! [String: Double])
  }
  
  private func show(_ call: FlutterMethodCall) {
    viewController.view.addSubview(mapView!)
  }
  
  private func setBounds(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let cameraPosition = mapView!.mapWindow.map!.cameraPosition(with:
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
  
  private func addPlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let point = YMKPoint(latitude: params["latitude"] as! Double, longitude: params["longitude"] as! Double)
    let mapObjects = mapView!.mapWindow.map!.mapObjects!
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
  
  private func removePlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let mapObjects = mapView!.mapWindow.map!.mapObjects!
    let placemark = placemarks.first(where: { $0.userData as! Int == params["hashCode"] as! Int })
    
    mapObjects.remove(with: placemark)
    placemarks.remove(at: placemarks.index(of: placemark!)!)
  }
  
  private func removePlacemarks(_ call: FlutterMethodCall) {
    mapView?.mapWindow.map!.mapObjects!.clear()
    placemarks.removeAll()
  }
  
  private func moveWithParams(_ params: [String: Any], _ cameraPosition: YMKCameraPosition) {
    if (params["animate"] as! Bool) {
      let type = params["smoothAnimation"] as! Bool ? YMKAnimationType.smooth : YMKAnimationType.linear
      let animationType = YMKAnimation(type: type, duration: params["animationDuration"] as! Float)
      
      mapView!.mapWindow.map!.move(with: cameraPosition, animationType: animationType)
    } else {
      mapView!.mapWindow.map!.move(with: cameraPosition)
    }
  }
  
  private func parseRect(_ rect: [String: Double]) -> CGRect {
    return CGRect(x: rect["left"]!, y: rect["top"]!, width: rect["width"]!, height: rect["height"]!)
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
