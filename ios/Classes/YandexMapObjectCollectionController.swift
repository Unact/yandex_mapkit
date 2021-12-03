import YandexMapsMobile

class YandexMapObjectCollectionController: NSObject, YandexMapObjectController, YMKMapObjectTapListener {
  private var mapObjectCollectionControllers: [YandexMapObjectCollectionController] = []
  private var clusterizedPlacemarkCollectionControllers: [YandexClusterizedPlacemarkCollectionController] = []
  private var placemarkControllers: [YandexPlacemarkController] = []
  private var circleControllers: [YandexCircleController] = []
  private var polylineControllers: [YandexPolylineController] = []
  private var polygonControllers: [YandexPolygonController] = []
  public let mapObjectCollection: YMKMapObjectCollection
  private var consumeTapEvents: Bool = false
  public unowned var controller: YandexMapController
  public let id: String

  internal init(
    root: YMKMapObjectCollection,
    id: String,
    controller: YandexMapController
  ) {
    self.mapObjectCollection = root
    self.id = id
    self.controller = controller

    super.init()

    mapObjectCollection.userData = self.id
    mapObjectCollection.addTapListener(with: self)
  }

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    let mapObjectCollection = parent.add()

    self.mapObjectCollection = mapObjectCollection
    self.id = params["id"] as! String
    self.controller = controller

    super.init()

    mapObjectCollection.userData = self.id
    mapObjectCollection.addTapListener(with: self)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    mapObjectCollection.zIndex = (params["zIndex"] as! NSNumber).floatValue
    mapObjectCollection.isVisible = (params["isVisible"] as! NSNumber).boolValue
    updateMapObjects(params["mapObjects"] as! [String: Any])

    consumeTapEvents = (params["consumeTapEvents"] as! NSNumber).boolValue
  }

  public func remove() {
    mapObjectCollectionControllers.forEach({ $0.remove() })
    clusterizedPlacemarkCollectionControllers.forEach({ $0.remove() })
    placemarkControllers.forEach({ $0.remove() })
    circleControllers.forEach({ $0.remove() })
    polylineControllers.forEach({ $0.remove() })
    polygonControllers.forEach({ $0.remove() })
    mapObjectCollection.parent.remove(with: mapObjectCollection)
  }

  private func updateMapObjects(_ mapObjects: [String: Any]) {
    addMapObjects(mapObjects["toAdd"] as! [[String: Any]])
    changeMapObjects(mapObjects["toChange"] as! [[String: Any]])
    removeMapObjects(mapObjects["toRemove"] as! [[String: Any]])
  }

  private func addMapObjects(_ toAdd: [[String: Any]]) {
    for el in toAdd {
      switch el["type"] as! String {
      case "Circle":
        addCircle(el)
        break
      case "MapObjectCollection":
        addMapObjectCollection(el)
        break
      case "Placemark":
        addPlacemark(el)
        break
      case "Polygon":
        addPolygon(el)
        break
      case "Polyline":
        addPolyline(el)
        break
      case "ClusterizedPlacemarkCollection":
        addClusterizedPlacemarkCollection(el)
        break
      default:
        break
      }
    }
  }

  private func changeMapObjects(_ toChange: [[String: Any]]) {
    for el in toChange {
      switch el["type"] as! String {
      case "Circle":
        changeCircle(el)
        break
      case "MapObjectCollection":
        changeMapObjectCollection(el)
        break
      case "Placemark":
        changePlacemark(el)
        break
      case "Polygon":
        changePolygon(el)
        break
      case "Polyline":
        changePolyline(el)
        break
      case "ClusterizedPlacemarkCollection":
        changeClusterizedPlacemarkCollection(el)
        break
      default:
        break
      }
    }
  }

  private func removeMapObjects(_ toRemove: [[String: Any]]) {
    for el in toRemove {
      switch el["type"] as! String {
      case "Circle":
        removeCircle(el)
        break
      case "MapObjectCollection":
        removeMapObjectCollection(el)
        break
      case "Placemark":
        removePlacemark(el)
        break
      case "Polygon":
        removePolygon(el)
        break
      case "Polyline":
        removePolyline(el)
        break
      case "ClusterizedPlacemarkCollection":
        removeClusterizedPlacemarkCollection(el)
        break
      default:
        break
      }
    }
  }

  private func addMapObjectCollection(_ params: [String: Any]) {
    let mapObjectCollectionController = YandexMapObjectCollectionController(
      parent: mapObjectCollection,
      params: params,
      controller: controller
    )

    mapObjectCollectionControllers.append(mapObjectCollectionController)
  }

  private func changeMapObjectCollection(_ params: [String: Any]) {
    let id = params["id"] as! String
    let mapObjectCollectionController = mapObjectCollectionControllers.first(where: { $0.id == id })!

    mapObjectCollectionController.update(params)
  }

  private func removeMapObjectCollection(_ params: [String: Any]) {
    let id = params["id"] as! String
    let mapObjectCollectionController = mapObjectCollectionControllers.first(where: { $0.id == id })!
    let idx = mapObjectCollectionControllers.firstIndex(of: mapObjectCollectionController)!

    mapObjectCollectionController.remove()
    mapObjectCollectionControllers.remove(at: idx)
  }

  private func addPlacemark(_ params: [String: Any]) {
    let placemarkController = YandexPlacemarkController(
      parent: mapObjectCollection,
      params: params,
      controller: controller
    )

    placemarkControllers.append(placemarkController)
  }

  private func changePlacemark(_ params: [String: Any]) {
    let id = params["id"] as! String
    let placemarkController = placemarkControllers.first(where: { $0.id == id })!

    placemarkController.update(params)
  }

  private func removePlacemark(_ params: [String: Any]) {
    let id = params["id"] as! String
    let placemarkController = placemarkControllers.first(where: { $0.id == id })!
    let idx = placemarkControllers.firstIndex(of: placemarkController)!

    placemarkController.remove()
    placemarkControllers.remove(at: idx)
  }

  private func addCircle(_ params: [String: Any]) {
    let circleController = YandexCircleController(
      parent: mapObjectCollection,
      params: params,
      controller: controller
    )

    circleControllers.append(circleController)
  }

  private func changeCircle(_ params: [String: Any]) {
    let id = params["id"] as! String
    let circleController = circleControllers.first(where: { $0.id == id })!

    circleController.update(params)
  }

  private func removeCircle(_ params: [String: Any]) {
    let id = params["id"] as! String
    let circleController = circleControllers.first(where: { $0.id == id })!
    let idx = circleControllers.firstIndex(of: circleController)!

    circleController.remove()
    circleControllers.remove(at: idx)
  }

  private func addPolyline(_ params: [String: Any]) {
    let polylineController = YandexPolylineController(
      parent: mapObjectCollection,
      params: params,
      controller: controller
    )

    polylineControllers.append(polylineController)
  }

  private func changePolyline(_ params: [String: Any]) {
    let id = params["id"] as! String
    let polylineController = polylineControllers.first(where: { $0.id == id })!

    polylineController.update(params)
  }

  private func removePolyline(_ params: [String: Any]) {
    let id = params["id"] as! String
    let polylineController = polylineControllers.first(where: { $0.id == id })!
    let idx = polylineControllers.firstIndex(of: polylineController)!

    polylineController.remove()
    polylineControllers.remove(at: idx)
  }

  private func addPolygon(_ params: [String: Any]) {
    let polygonController = YandexPolygonController(
      parent: mapObjectCollection,
      params: params,
      controller: controller
    )

    polygonControllers.append(polygonController)
  }

  private func changePolygon(_ params: [String: Any]) {
    let id = params["id"] as! String
    let polygonController = polygonControllers.first(where: { $0.id == id })!

    polygonController.update(params)
  }

  private func removePolygon(_ params: [String: Any]) {
    let id = params["id"] as! String
    let polygonController = polygonControllers.first(where: { $0.id == id })!
    let idx = polygonControllers.firstIndex(of: polygonController)!

    polygonController.remove()
    polygonControllers.remove(at: idx)
  }

  private func addClusterizedPlacemarkCollection(_ params: [String: Any]) {
    let clusterizedPlacemarkCollectionController = YandexClusterizedPlacemarkCollectionController(
      parent: mapObjectCollection,
      params: params,
      controller: controller
    )

    clusterizedPlacemarkCollectionControllers.append(clusterizedPlacemarkCollectionController)
  }

  private func changeClusterizedPlacemarkCollection(_ params: [String: Any]) {
    let id = params["id"] as! String
    let clusterizedPlacemarkCollectionController = clusterizedPlacemarkCollectionControllers.first(
      where: { $0.id == id }
    )!

    clusterizedPlacemarkCollectionController.update(params)
  }

  private func removeClusterizedPlacemarkCollection(_ params: [String: Any]) {
    let id = params["id"] as! String
    let clusterizedPlacemarkCollectionController = clusterizedPlacemarkCollectionControllers.first(
      where: { $0.id == id }
    )!
    let idx = clusterizedPlacemarkCollectionControllers.firstIndex(of: clusterizedPlacemarkCollectionController)!

    clusterizedPlacemarkCollectionController.remove()
    clusterizedPlacemarkCollectionControllers.remove(at: idx)
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
