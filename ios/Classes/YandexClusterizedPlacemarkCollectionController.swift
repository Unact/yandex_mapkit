import YandexMapsMobile

class YandexClusterizedPlacemarkCollectionController:
  NSObject,
  YandexMapObjectController,
  YMKClusterListener,
  YMKClusterTapListener,
  YMKMapObjectTapListener
{
  private var clusterCnt: Int = 0
  private var clusters: [YMKCluster: YandexPlacemarkController] = [:]
  private var placemarkControllers: [YandexPlacemarkController] = []
  private let parent: YMKMapObjectCollection
  public lazy var clusterizedPlacemarkCollection: YMKClusterizedPlacemarkCollection = {
    parent.addClusterizedPlacemarkCollection(with: self)
  }()
  private var consumeTapEvents: Bool = false
  public unowned var controller: YandexMapController
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
    placemarkControllers.forEach({ $0.remove() })
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
    let placemarkController = YandexPlacemarkController(
      parent: clusterizedPlacemarkCollection,
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

    guard
      let placemarkController = placemarkControllers.first(where: { $0.id == id }),
      let idx = placemarkControllers.firstIndex(of: placemarkController)
    else { return }

    placemarkController.remove()
    placemarkControllers.remove(at: idx)
  }

  public func removeClusters() {
    let arguments: [String: Any?] = [
      "appearancePlacemarkIds": clusters.values.map({ $0.id })
    ]

    clusters.values.forEach({ $0.remove() })
    clusters.removeAll()

    controller.methodChannel.invokeMethod("onClustersRemoved", arguments: arguments)
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

    controller.methodChannel.invokeMethod("onClusterAdded", arguments: arguments) { result in
      guard let params = result as? [String: Any] else { return }

      if (!cluster.isValid) {
        return
      }

      self.clusters[cluster] = YandexPlacemarkController(
        parent: self.clusterizedPlacemarkCollection,
        placemark: cluster.appearance,
        params: params,
        controller: self.controller
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

    controller.methodChannel.invokeMethod("onClusterTap", arguments: arguments)

    return true
  }

  func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
    controller.mapObjectTap(id: id, point: point)

    return consumeTapEvents
  }
}
