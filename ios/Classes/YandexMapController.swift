import CoreLocation
import Flutter
import UIKit
import YandexMapKit
import YandexMapKitSearch

public class YandexMapController: NSObject, FlutterPlatformView {
  private let methodChannel: FlutterMethodChannel!
  private let pluginRegistrar: FlutterPluginRegistrar!
  private let mapObjectTapListener: MapObjectTapListener!
  private var userLocationObjectListener: UserLocationObjectListener?
  private var userLocationLayer: YMKUserLocationLayer?
  private var cameraTargetPlacemark: YMKPlacemarkMapObject?
  private var placemarks: [YMKPlacemarkMapObject] = []
  private var polylines: [YMKPolylineMapObject] = []
  private var polygons: [YMKPolygonMapObject] = []
  public let mapView: YMKMapView
  
  private var searchManager: YMKSearchManager?
  private var suggestSession: YMKSearchSuggestSession?

  public required init(id: Int64, frame: CGRect, registrar: FlutterPluginRegistrar) {
    self.pluginRegistrar = registrar
    self.mapView = YMKMapView(frame: frame)
    self.methodChannel = FlutterMethodChannel(
      name: "yandex_mapkit/yandex_map_\(id)",
      binaryMessenger: registrar.messenger()
    )
    self.mapObjectTapListener = MapObjectTapListener(channel: methodChannel)
    self.userLocationLayer =
                YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
    super.init()
    
    searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    
    self.mapView.mapWindow.map.addCameraListener(with: self)
    
    self.methodChannel.setMethodCallHandler(self.handle)
  }

  public func view() -> UIView {
    return self.mapView
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "showUserLayer":
      showUserLayer(call)
      result(nil)
    case "hideUserLayer":
      hideUserLayer()
      result(nil)
    case "setMapStyle":
      setMapStyle(call)
      result(nil)
    case "move":
      move(call)
      result(nil)
    case "setBounds":
      setBounds(call)
      result(nil)
    case "enableCameraTargetPlacemark":
      enableCameraTargetPlacemark(call)
      result(nil)
    case "disableCameraTargetPlacemark":
      disableCameraTargetPlacemark()
      result(nil)
    case "addPlacemark":
      addPlacemark(call)
      result(nil)
    case "removePlacemark":
      removePlacemark(call)
      result(nil)
    case "addPolyline":
      addPolyline(call)
      result(nil)
    case "removePolyline":
      removePolyline(call)
      result(nil)
    case "addPolygon":
      addPolygon(call)
      result(nil)
    case "removePolygon":
      removePolygon(call)
      result(nil)
    case "zoomIn":
        zoomIn()
        result(nil)
    case "zoomOut":
        zoomOut()
        result(nil)
    case "getTargetPoint":
        let targetPoint = getTargetPoint()
        result(targetPoint)
    case "moveToUser":
      moveToUser()
      result(nil)
    case "getSuggestions":
      getSuggestions(call)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func showUserLayer(_ call: FlutterMethodCall) {
    if (!hasLocationPermission()) { return }

    let params = call.arguments as! [String: Any]
    self.userLocationObjectListener = UserLocationObjectListener(
      pluginRegistrar: pluginRegistrar,
      iconName: params["iconName"] as! String,
      arrowName: params["arrowName"] as! String,
      userArrowOrientation: params["userArrowOrientation"] as! Bool,
      accuracyCircleFillColor: uiColor(fromInt: params["accuracyCircleFillColor"] as! Int64)
    )
    userLocationLayer?.setVisibleWithOn(true)
    userLocationLayer!.isHeadingEnabled = true
    userLocationLayer!.setObjectListenerWith(userLocationObjectListener!)
  }

  public func hideUserLayer() {
    if (!hasLocationPermission()) { return }

    userLocationLayer?.setVisibleWithOn(false)
  }

  public func setMapStyle(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let map = mapView.mapWindow.map
    map.setMapStyleWithStyle(params["style"] as! String)
  }
    
    public func zoomIn() {
        zoom(1)
    }
    
    public func zoomOut() {
        zoom(-1)
    }
    
    private func zoom(_ step: Float) {
        let point = mapView.mapWindow.map.cameraPosition.target
        let zoom = mapView.mapWindow.map.cameraPosition.zoom
        let azimuth = mapView.mapWindow.map.cameraPosition.azimuth
        let tilt = mapView.mapWindow.map.cameraPosition.tilt
        let currentPosition = YMKCameraPosition(
            target: point,
            zoom: zoom+step,
            azimuth: azimuth,
            tilt: tilt
         )
        mapView.mapWindow.map.move(
            with: currentPosition,
            animationType: YMKAnimation(
                type: YMKAnimationType.smooth,
                duration: 1
                ),
            cameraCallback: nil
        )
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

  public func setBounds(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let cameraPosition = mapView.mapWindow.map.cameraPosition(with:
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
    
  public func getTargetPoint() -> [String: Any] {
    let targetPoint = mapView.mapWindow.map.cameraPosition.target;
    let arguments: [String: Any] = [
        "hashCode": targetPoint.hashValue,
        "latitude": targetPoint.latitude,
        "longitude": targetPoint.longitude
    ]
    return arguments
  }
    
  public func addPlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let point = YMKPoint(latitude: params["latitude"] as! Double, longitude: params["longitude"] as! Double)
    let mapObjects = mapView.mapWindow.map.mapObjects
    let placemark = mapObjects.addPlacemark(with: point)
    let iconName = params["iconName"] as? String

    placemark.addTapListener(with: mapObjectTapListener)
    placemark.userData = params["hashCode"] as! Int
    placemark.opacity = (Float)(params["opacity"] as! Double)
    placemark.isDraggable = params["isDraggable"] as! Bool

    if (iconName != nil) {
      placemark.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!))!)
    }

    if let rawImageData = params["rawImageData"] as? FlutterStandardTypedData, 
      let image = UIImage(data: rawImageData.data) {
        placemark.setIconWith(image)
    }

    let iconStyle = YMKIconStyle()
    iconStyle.anchor = NSValue(cgPoint: CGPoint(x: (CGFloat)(params["anchorX"] as! Double), y: (CGFloat)(params["anchorY"] as! Double)))
    iconStyle.zIndex = NSNumber(value: (Float)(params["zIndex"] as! Double))
    iconStyle.scale = NSNumber(value: (Float)(params["scale"] as! Double))
    placemark.setIconStyleWith(iconStyle)

    placemarks.append(placemark)
  }

  public func removePlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let mapObjects = mapView.mapWindow.map.mapObjects
    let placemark = placemarks.first(where: { $0.userData as! Int == params["hashCode"] as! Int })

    if (placemark != nil) {
      mapObjects.remove(with: placemark!)
      placemarks.remove(at: placemarks.firstIndex(of: placemark!)!)
    }
  }

  public func enableCameraTargetPlacemark(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let point = mapView.mapWindow.map.cameraPosition.target;
    let mapObjects = mapView.mapWindow.map.mapObjects
    cameraTargetPlacemark = mapObjects.addPlacemark(with: point)
    
    let iconName = params["iconName"] as? String

    cameraTargetPlacemark!.addTapListener(with: mapObjectTapListener)
    cameraTargetPlacemark!.userData = params["hashCode"] as! Int
    cameraTargetPlacemark!.opacity = (Float)(params["opacity"] as! Double)
    cameraTargetPlacemark!.isDraggable = params["isDraggable"] as! Bool

    if (iconName != nil) {
      cameraTargetPlacemark!.setIconWith(UIImage(named: pluginRegistrar.lookupKey(forAsset: iconName!))!)
    }

    if let rawImageData = params["rawImageData"] as? FlutterStandardTypedData, 
      let image = UIImage(data: rawImageData.data) {
      cameraTargetPlacemark!.setIconWith(image)
    }

    let iconStyle = YMKIconStyle()
    iconStyle.anchor = NSValue(cgPoint: CGPoint(x: (CGFloat)(params["anchorX"] as! Double), y: (CGFloat)(params["anchorY"] as! Double)))
    iconStyle.zIndex = NSNumber(value: (Float)(params["zIndex"] as! Double))
    iconStyle.scale = NSNumber(value: (Float)(params["scale"] as! Double))
    cameraTargetPlacemark!.setIconStyleWith(iconStyle)
  }

  public func disableCameraTargetPlacemark() {
    if cameraTargetPlacemark != nil {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: cameraTargetPlacemark!)
      cameraTargetPlacemark = nil
    }
  }

  private func addPolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let coordinates = params["coordinates"] as! [[String: Any]]
    let coordinatesPrepared = coordinates.map { YMKPoint(latitude: $0["latitude"] as! Double, longitude: $0["longitude"] as! Double)}
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polyline = YMKPolyline(points: coordinatesPrepared)
    let polylineMapObject = mapObjects.addPolyline(with: polyline)
    polylineMapObject.userData = params["hashCode"] as! Int
    polylineMapObject.strokeColor = uiColor(fromInt: params["strokeColor"] as! Int64)
    polylineMapObject.outlineColor = uiColor(fromInt: params["outlineColor"] as! Int64)
    polylineMapObject.outlineWidth = params["outlineWidth"] as! Float
    polylineMapObject.strokeWidth = params["strokeWidth"] as! Float
    polylineMapObject.isGeodesic = params["isGeodesic"] as! Bool
    polylineMapObject.dashLength = params["dashLength"] as! Float
    polylineMapObject.dashOffset = params["dashOffset"] as! Float
    polylineMapObject.gapLength = params["gapLength"] as! Float
    polylines.append(polylineMapObject)
  }

  private func removePolyline(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let hashCode = params["hashCode"] as! Int

    if let polyline = polylines.first(where: { $0.userData as! Int ==  hashCode}) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: polyline)
      polylines.remove(at: polylines.firstIndex(of: polyline)!)
    }
  }

  public func addPolygon(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let coordinates = params["coordinates"] as! [[String: Any]]
    let coordinatesPrepared = coordinates.map { YMKPoint(latitude: $0["latitude"] as! Double, longitude: $0["longitude"] as! Double)}
    let mapObjects = mapView.mapWindow.map.mapObjects
    let polylgon = YMKPolygon(outerRing: YMKLinearRing(points: coordinatesPrepared), innerRings: [])
    let polygonMapObject = mapObjects.addPolygon(with: polylgon)
    polygonMapObject.userData = params["hashCode"] as! Int
    polygonMapObject.strokeColor = uiColor(fromInt: params["strokeColor"] as! Int64)
    polygonMapObject.strokeWidth = params["strokeWidth"] as! Float
    polygonMapObject.fillColor = uiColor(fromInt: params["fillColor"] as! Int64)
    polygonMapObject.isGeodesic = params["isGeodesic"] as! Bool
    polygons.append(polygonMapObject)
  }
  
  public func removePolygon(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let hashCode = params["hashCode"] as! Int

    if let polygon = polygons.first(where: { $0.userData as! Int ==  hashCode}) {
      let mapObjects = mapView.mapWindow.map.mapObjects
      mapObjects.remove(with: polygon)
      polygons.remove(at: polygons.firstIndex(of: polygon)!)
    }
  }

  public func getSuggestions(_ call: FlutterMethodCall) {
    let params = call.arguments as! [String: Any]
    let boundingBox = YMKBoundingBox.init(southWest: YMKPoint.init(latitude: params["southWestLatitude"] as! Double,
                                                                   longitude: params["southWestLongitude"] as! Double),
                                          northEast: YMKPoint.init(latitude: params["northEastLatitude"] as! Double,
                                                                   longitude: params["northEastLongitude"] as! Double))
    let formattedAddress = params["formattedAddress"] as! String
    
    let responseHandler = {(searchResponse: [YMKSuggestItem]?, error: Error?) -> Void in
      if searchResponse != nil {
        var suggestItems = [Any]()
        for suggestItem in searchResponse! {
          var dict = [String : Any]()
          dict["title"] = suggestItem.title.text
          if (suggestItem.subtitle != nil) {
            dict["subtitle"] = suggestItem.subtitle?.text
          }
          if (suggestItem.displayText != nil) {
            dict["displayText"] = suggestItem.displayText
          }
          dict["searchText"] = suggestItem.searchText;
          dict["tags"] = suggestItem.tags;
          var suggestItemType = String()
          switch suggestItem.type {
          case .toponym:
              suggestItemType = "TOPONYM"
          case .business:
              suggestItemType = "BUSINESS"
          case .transit:
              suggestItemType = "TRANSIT"
          default:
              suggestItemType = "UNKNOWN"
          }
          dict["type"] = suggestItemType;
          suggestItems.append(dict)
        }
        let arguments: [String:Any?] = [
          "suggests": suggestItems
        ]
        self.methodChannel.invokeMethod("onSuggestResponseTitles", arguments: arguments)
      }
    }

    if suggestSession == nil {
      suggestSession = searchManager?.createSuggestSession()
    }
    
    var suggestType = YMKSuggestType()
    switch params["suggestType"] as! String {
    case "GEO":
      suggestType = YMKSuggestType.geo
    case "BIZ":
      suggestType = YMKSuggestType.biz
    case "TRANSIT":
      suggestType = YMKSuggestType.transit
    default:
      suggestType = YMKSuggestType.init(rawValue: 0)
    }
    let suggestOptions = YMKSuggestOptions.init(suggestTypes: suggestType,
                                                userPosition: nil,
                                                suggestWords: params["suggestWords"] as! Bool)
    suggestSession?.suggest(withText: formattedAddress, window: boundingBox!, suggestOptions: suggestOptions, responseHandler: responseHandler)
  }

  public func moveToUser() {
    if (!hasLocationPermission()) { return }
    let zoom = mapView.mapWindow.map.cameraPosition.zoom
    let azimuth = mapView.mapWindow.map.cameraPosition.azimuth
    let tilt = mapView.mapWindow.map.cameraPosition.tilt
    if let target = userLocationLayer?.cameraPosition()?.target {
      let cameraPosition = YMKCameraPosition(
        target: target,
        zoom: zoom,
        azimuth: azimuth,
        tilt: tilt
      )
      mapView.mapWindow.map.move(with: cameraPosition, animationType: YMKAnimation.init(type: YMKAnimationType.smooth, duration: 1), cameraCallback: nil)
    }
  }

  private func moveWithParams(_ params: [String: Any], _ cameraPosition: YMKCameraPosition) {
    if (params["animate"] as! Bool) {
      let type = params["smoothAnimation"] as! Bool ? YMKAnimationType.smooth : YMKAnimationType.linear
      let animationType = YMKAnimation(type: type, duration: params["animationDuration"] as! Float)

      mapView.mapWindow.map.move(with: cameraPosition, animationType: animationType)
    } else {
      mapView.mapWindow.map.move(with: cameraPosition)
    }
  }

  private func hasLocationPermission() -> Bool {
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied:
        return false
      case .authorizedAlways, .authorizedWhenInUse:
        return true
      default:
        return false
      }
    } else {
      return false
    }
  }

  private func uiColor(fromInt value: Int64) -> UIColor {
    return UIColor(red: CGFloat((value & 0xFF0000) >> 16) / 0xFF, 
                   green: CGFloat((value & 0x00FF00) >> 8) / 0xFF,
                   blue: CGFloat(value & 0x0000FF) / 0xFF,
                   alpha: CGFloat((value & 0xFF000000) >> 24) / 0xFF)
  }

  internal class UserLocationObjectListener: NSObject, YMKUserLocationObjectListener {
    private let pluginRegistrar: FlutterPluginRegistrar!
    private let iconName: String!
    private let arrowName: String!
    private let userArrowOrientation: Bool!
    private let accuracyCircleFillColor: UIColor!

    public required init(pluginRegistrar: FlutterPluginRegistrar, iconName: String, arrowName: String, userArrowOrientation: Bool, accuracyCircleFillColor: UIColor) {
      self.pluginRegistrar = pluginRegistrar
      self.iconName = iconName
      self.arrowName = arrowName
      self.userArrowOrientation = userArrowOrientation
      self.accuracyCircleFillColor = accuracyCircleFillColor
    }

    func onObjectAdded(with view: YMKUserLocationView) {
      view.pin.setIconWith(
        UIImage(named: pluginRegistrar.lookupKey(forAsset: self.iconName))!
      )
      view.arrow.setIconWith(
        UIImage(named: pluginRegistrar.lookupKey(forAsset: self.arrowName))!
      )
      if (userArrowOrientation) {
        view.arrow.setIconStyleWith(YMKIconStyle(anchor: nil,
                                                 rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                                                 zIndex: nil,
                                                 flat: nil,
                                                 visible: nil,
                                                 scale: nil,
                                                 tappableArea: nil))
      }
      view.accuracyCircle.fillColor = accuracyCircleFillColor
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
  }

  internal class MapObjectTapListener: NSObject, YMKMapObjectTapListener {
    private let methodChannel: FlutterMethodChannel!

    public required init(channel: FlutterMethodChannel) {
      self.methodChannel = channel
    }

    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
      let arguments: [String:Any?] = [
        "hashCode": mapObject.userData,
        "latitude": point.latitude,
        "longitude": point.longitude
      ]
      methodChannel.invokeMethod("onMapObjectTap", arguments: arguments)

      return true
    }
  }
}

extension YandexMapController: YMKMapCameraListener {
  public func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateSource: YMKCameraUpdateSource, finished: Bool) {
    let point = cameraPosition.target

    cameraTargetPlacemark?.geometry = point

    let arguments: [String:Any?] = [
      "latitude": point.latitude,
      "longitude": point.longitude,
      "final": finished
    ]
    methodChannel.invokeMethod("onCameraPositionChanged", arguments: arguments)
  }
}
