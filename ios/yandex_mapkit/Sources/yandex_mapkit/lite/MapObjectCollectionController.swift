import YandexMapsMobile

class MapObjectCollectionController: NSObject, MapObjectController, YMKMapObjectTapListener {
  private var mapObjectCollections: [String: MapObjectCollectionController] = [:]
  private var clusterizedPlacemarkCollections: [String: ClusterizedPlacemarkCollectionController] = [:]
  private var placemarks: [String: PlacemarkMapObjectController] = [:]
  private var circles: [String: CircleMapObjectController] = [:]
  private var polylines: [String: PolylineMapObjectController] = [:]
  private var polygons: [String: PolygonMapObjectController] = [:]
  public let mapObjectCollection: YMKMapObjectCollection
  private var consumeTapEvents: Bool = false
  public weak var controller: YandexMapController?
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
    mapObjectCollections.forEach({ $0.value.remove() })
    clusterizedPlacemarkCollections.forEach({ $0.value.remove() })
    placemarks.forEach({ $0.value.remove() })
    circles.forEach({ $0.value.remove() })
    polylines.forEach({ $0.value.remove() })
    polygons.forEach({ $0.value.remove() })

    mapObjectCollections.removeAll()
    clusterizedPlacemarkCollections.removeAll()
    placemarks.removeAll()
    circles.removeAll()
    polylines.removeAll()
    polygons.removeAll()

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
      case "CircleMapObject":
        addCircle(el)
        break
      case "MapObjectCollection":
        addMapObjectCollection(el)
        break
      case "PlacemarkMapObject":
        addPlacemark(el)
        break
      case "PolygonMapObject":
        addPolygon(el)
        break
      case "PolylineMapObject":
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
      case "CircleMapObject":
        changeCircle(el)
        break
      case "MapObjectCollection":
        changeMapObjectCollection(el)
        break
      case "PlacemarkMapObject":
        changePlacemark(el)
        break
      case "PolygonMapObject":
        changePolygon(el)
        break
      case "PolylineMapObject":
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
      case "CircleMapObject":
        removeCircle(el)
        break
      case "MapObjectCollection":
        removeMapObjectCollection(el)
        break
      case "PlacemarkMapObject":
        removePlacemark(el)
        break
      case "PolygonMapObject":
        removePolygon(el)
        break
      case "PolylineMapObject":
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
    let mapObjectCollectionController = MapObjectCollectionController(
      parent: mapObjectCollection,
      params: params,
      controller: controller!
    )

    mapObjectCollections[mapObjectCollectionController.id] = mapObjectCollectionController
  }

  private func changeMapObjectCollection(_ params: [String: Any]) {
    let id = params["id"] as! String

    mapObjectCollections[id]?.update(params)
  }

  private func removeMapObjectCollection(_ params: [String: Any]) {
    let id = params["id"] as! String

    mapObjectCollections[id]?.remove()
    mapObjectCollections.removeValue(forKey: id)
  }

  private func addPlacemark(_ params: [String: Any]) {
    let placemarkController = PlacemarkMapObjectController(
      parent: mapObjectCollection,
      params: params,
      controller: controller!
    )

    placemarks[placemarkController.id] = placemarkController
  }

  private func changePlacemark(_ params: [String: Any]) {
    let id = params["id"] as! String

    placemarks[id]?.update(params)
  }

  private func removePlacemark(_ params: [String: Any]) {
    let id = params["id"] as! String

    placemarks[id]?.remove()
    placemarks.removeValue(forKey: id)
  }

  private func addCircle(_ params: [String: Any]) {
    let circleController = CircleMapObjectController(
      parent: mapObjectCollection,
      params: params,
      controller: controller!
    )

    circles[circleController.id] = circleController
  }

  private func changeCircle(_ params: [String: Any]) {
    let id = params["id"] as! String

    circles[id]?.update(params)
  }

  private func removeCircle(_ params: [String: Any]) {
    let id = params["id"] as! String

    circles[id]?.remove()
    circles.removeValue(forKey: id)
  }

  private func addPolyline(_ params: [String: Any]) {
    let polylineController = PolylineMapObjectController(
      parent: mapObjectCollection,
      params: params,
      controller: controller!
    )

    polylines[polylineController.id] = polylineController
  }

  private func changePolyline(_ params: [String: Any]) {
    let id = params["id"] as! String

    polylines[id]?.update(params)
  }

  private func removePolyline(_ params: [String: Any]) {
    let id = params["id"] as! String

    polylines[id]?.remove()
    polylines.removeValue(forKey: id)
  }

  private func addPolygon(_ params: [String: Any]) {
    let polygonController = PolygonMapObjectController(
      parent: mapObjectCollection,
      params: params,
      controller: controller!
    )

    polygons[polygonController.id] = polygonController
  }

  private func changePolygon(_ params: [String: Any]) {
    let id = params["id"] as! String

    polygons[id]?.update(params)
  }

  private func removePolygon(_ params: [String: Any]) {
    let id = params["id"] as! String

    polygons[id]?.remove()
    polygons.removeValue(forKey: id)
  }

  private func addClusterizedPlacemarkCollection(_ params: [String: Any]) {
    let clusterizedPlacemarkCollectionController = ClusterizedPlacemarkCollectionController(
      parent: mapObjectCollection,
      params: params,
      controller: controller!
    )

    clusterizedPlacemarkCollections[clusterizedPlacemarkCollectionController.id] =
      clusterizedPlacemarkCollectionController
  }

  private func changeClusterizedPlacemarkCollection(_ params: [String: Any]) {
    let id = params["id"] as! String

    clusterizedPlacemarkCollections[id]?.update(params)
  }

  private func removeClusterizedPlacemarkCollection(_ params: [String: Any]) {
    let id = params["id"] as! String

    clusterizedPlacemarkCollections[id]?.remove()
    clusterizedPlacemarkCollections.removeValue(forKey: id)
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller!.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
