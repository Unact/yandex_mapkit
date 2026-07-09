// swift-tools-version: 5.6
import PackageDescription
import Foundation

let variant = ProcessInfo.processInfo.environment["YANDEX_MAPKIT_VARIANT"] ?? "lite"
let sources = variant == "full" ?
  ["Init.swift", "YandexMapkitPlugin.swift", "lite/", "full/"] :
  ["Init.swift", "YandexMapkitPlugin.swift", "lite/"]
let variant_name = "mapkit-ios\(variant == "full" ? "" : "-lite")"
let url = "https://github.com/yandex/\(variant_name)"
let package_name = variant == "full" ? "YandexMapsMobileFull" : "YandexMapsMobileLite"
let package = Package(
  name: "yandex_mapkit",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "yandex-mapkit", targets: ["yandex_mapkit"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
    .package(url: url, exact: "4.39.1")
  ],
  targets: [
    .target(
      name: "yandex_mapkit",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        .product(name: package_name, package: variant_name)
      ],
      path: "Sources/yandex_mapkit",
      sources: sources,
      resources: [],
      swiftSettings: [
        .define("YANDEX_MAPKIT_\(variant.uppercased())")
      ],
      linkerSettings: [
        .unsafeFlags(["-ObjC"])
      ]
    )
  ]
)
