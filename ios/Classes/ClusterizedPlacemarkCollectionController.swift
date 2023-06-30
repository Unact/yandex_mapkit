import YandexMapsMobile

class ClusterizedPlacemarkCollectionController:
  NSObject,
  MapObjectController,
  YMKClusterListener,
  YMKClusterTapListener,
  YMKMapObjectTapListener
{
  private var clusterCnt: Int = 0
  private var clusters: [YMKCluster: PlacemarkMapObjectController] = [:]
  private var placemarks: [String: PlacemarkMapObjectController] = [:]
  private let parent: YMKMapObjectCollection
  public lazy var clusterizedPlacemarkCollection: YMKClusterizedPlacemarkCollection = {
    parent.addClusterizedPlacemarkCollection(with: self)
  }()
  private var consumeTapEvents: Bool = false
  public weak var controller: YandexMapController?
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    self.id = params["id"] as! String
    self.controller = controller
    self.parent = parent

    super.init()

    clusterizedPlacemarkCollection.userData = self.id
    clusterizedPlacemarkCollection.addTapListener(with: self)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    updatePlacemarks(params["placemarks"] as! [String: Any])
    clusterizedPlacemarkCollection.isVisible = (params["isVisible"] as! NSNumber).boolValue
    clusterizedPlacemarkCollection.clusterPlacemarks(
      withClusterRadius: (params["radius"] as! NSNumber).doubleValue,
      minZoom: (params["minZoom"] as! NSNumber).uintValue
    )

    consumeTapEvents = (params["consumeTapEvents"] as! NSNumber).boolValue
  }

  public func remove() {
    placemarks.forEach({ $0.value.remove() })
    placemarks.removeAll()
    clusterizedPlacemarkCollection.parent.remove(with: clusterizedPlacemarkCollection)

    removeClusters()
  }

  private func updatePlacemarks(_ placemarks: [String: Any]) {
    addPlacemaks(placemarks["toAdd"] as! [[String: Any]])
    changePlacemarks(placemarks["toChange"] as! [[String: Any]])
    removePlacemarks(placemarks["toRemove"] as! [[String: Any]])
  }

  private func addPlacemaks(_ toAdd: [[String: Any]]) {
    for el in toAdd {
      addPlacemark(el)
    }
  }

  private func changePlacemarks(_ toChange: [[String: Any]]) {
    for el in toChange {
      changePlacemark(el)
    }
  }

  private func removePlacemarks(_ toRemove: [[String: Any]]) {
    for el in toRemove {
      removePlacemark(el)
    }
  }

  private func addPlacemark(_ params: [String: Any]) {
    let placemarkController = PlacemarkMapObjectController(
      parent: clusterizedPlacemarkCollection,
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

  public func removeClusters() {
    let arguments: [String: Any?] = [
      "appearancePlacemarkIds": clusters.values.map({ $0.id })
    ]

    clusters.values.forEach({ $0.remove() })
    clusters.removeAll()

    controller!.methodChannel.invokeMethod("onClustersRemoved", arguments: arguments)
  }

  internal func onClusterAdded(with cluster: YMKCluster) {
    clusterCnt += 1
    let arguments: [String: Any?] = [
      "id": id,
      "appearancePlacemarkId": id + "_appearance_placemark_" + String(clusterCnt),
      "size": cluster.size,
      "point": Utils.pointToJson(cluster.appearance.geometry),
      "placemarkIds": cluster.placemarks.map({$0.userData as! String})
    ]

    controller!.methodChannel.invokeMethod("onClusterAdded", arguments: arguments) { result in
      if (
        result is FlutterError ||
        self.controller == nil ||
        !self.clusterizedPlacemarkCollection.isValid ||
        !cluster.isValid ||
        !cluster.appearance.isValid
      ) {
        return
      }

      let params = result as! [String: Any]

      self.clusters[cluster] = PlacemarkMapObjectController(
        placemark: cluster.appearance,
        params: params,
        controller: self.controller!
      )
      cluster.addClusterTapListener(with: self)
    }
  }

  internal func onClusterTap(with cluster: YMKCluster) -> Bool {
    let arguments: [String: Any?] = [
      "id": id,
      "appearancePlacemarkId": clusters[cluster]!.id,
      "size": cluster.size,
      "point": Utils.pointToJson(cluster.appearance.geometry),
      "placemarkIds": cluster.placemarks.map({$0.userData as! String})
    ]

    controller!.methodChannel.invokeMethod("onClusterTap", arguments: arguments)

    return true
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller!.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
