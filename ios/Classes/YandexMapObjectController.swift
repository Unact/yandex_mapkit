protocol YandexMapObjectController {
  var id: String { get }

  func update(_ params: [String: Any])
  func remove()
}
