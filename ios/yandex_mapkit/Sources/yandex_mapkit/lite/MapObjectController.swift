protocol MapObjectController {
  var id: String { get }
  var controller: YandexMapController? { get }

  func update(_ params: [String: Any])
  func remove()
}
