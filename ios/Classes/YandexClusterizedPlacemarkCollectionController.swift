import YandexMapsMobile

class YandexClusterizedPlacemarkCollectionController:
  NSObject,
  YandexMapObjectController,
  YMKClusterListener,
  YMKClusterTapListener
{
  private var clusterCnt: Int = 0
  private var clusters: [YMKCluster: YandexPlacemarkController] = [:]
  private var placemarkControllers: [YandexPlacemarkController] = []
  private let parent: YMKMapObjectCollection
  public lazy var clusterizedPlacemarkCollection: YMKClusterizedPlacemarkCollection = {
    parent.addClusterizedPlacemarkCollection(with: self)
  }()
  private let tapListener: YandexMapObjectTapListener
  private unowned var controller: YandexMapController
  public let id: String

  public required init(
    parent: YMKMapObjectCollection,
    params: [String: Any],
    controller: YandexMapController
  ) {
    self.id = params["id"] as! String
    self.controller = controller
    self.tapListener = YandexMapObjectTapListener(id: id, controller: controller)
    self.parent = parent

    super.init()

    clusterizedPlacemarkCollection.addTapListener(with: tapListener)
    update(params)
  }

  public func update(_ params: [String: Any]) {
    updatePlacemarks(params["placemarks"] as! [String: Any])
    clusterizedPlacemarkCollection.clusterPlacemarks(
      withClusterRadius: (params["radius"] as! NSNumber).doubleValue,
      minZoom: (params["minZoom"] as! NSNumber).uintValue
    )
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
    let placemarkController = placemarkControllers.first(where: { $0.id == id })!
    let idx = placemarkControllers.firstIndex(of: placemarkController)!

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
      "placemarkIds": placemarkControllers.filter({ cluster.placemarks.contains($0.placemark)}).map({ $0.id })
    ]

    controller.methodChannel.invokeMethod("onClusterAdded", arguments: arguments) { result in
      let params = result as! [String: Any]

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
      "placemarkIds": placemarkControllers.filter({ cluster.placemarks.contains($0.placemark)}).map({ $0.id })
    ]

    controller.methodChannel.invokeMethod("onClusterTap", arguments: arguments)

    return true
  }
}
