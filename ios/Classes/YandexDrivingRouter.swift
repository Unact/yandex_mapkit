import Flutter
import UIKit
import YandexMapsMobile

public class YandexDrivingRouter: NSObject, FlutterPlugin {
    private let methodChannel: FlutterMethodChannel!
    private var router: YMKDrivingRouter?
    private var session: YMKDrivingSession?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "yandex_mapkit/yandex_driving",
            binaryMessenger: registrar.messenger()
        )
        let plugin = YandexDrivingRouter(channel: channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }
    
    public required init(channel: FlutterMethodChannel) {
        methodChannel = channel
        super.init()
        methodChannel.setMethodCallHandler(handle)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestRoutes":
            requestRoutes(call, result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func requestRoutes(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        router = router ?? YMKDirections.sharedInstance().createDrivingRouter()
        let params = call.arguments as! [String: Any]
        let pointsParams = params["points"] as! [[String: Any]]
        let requestPoints = pointsParams.map { (pointParams) ->YMKRequestPoint in
            requestPoint(pointParams)
        }
        let drivingOptions = YMKDrivingDrivingOptions()
        let vehicleOptions = YMKDrivingVehicleOptions()

        session = router!.requestRoutes(with: requestPoints, drivingOptions: drivingOptions, vehicleOptions: vehicleOptions) { (routes, error) in
            guard let routes: [YMKDrivingRoute] = routes else {
                if(error != nil){
                    result(error)
                }
                return
            }
            let resultRoutes: [[String: Any]] = routes
                .map { (route) -> [String: Any] in
                    let resultpoints: [[String: Any]] = route.geometry.points.map { (point) -> [String: Any] in
                        return ["latitude": point.latitude, "longitude": point.longitude]
                    }
                    let resultRoute: [String: Any] = ["geometry": resultpoints]
                    return resultRoute
                }
            result(resultRoutes)
        }
    }
    
    private func requestPoint(_ data: [String: Any]) -> YMKRequestPoint {
        let paramsPoint = data["point"] as! [String: Any]
        let point = YMKPoint(latitude: (paramsPoint["latitude"] as! NSNumber).doubleValue, longitude: (paramsPoint["longitude"] as! NSNumber).doubleValue)
        let pointType: YMKRequestPointType
        switch data["requestPointType"] as! String {
            case "VIAPOINT":
                pointType = YMKRequestPointType.viapoint
            case "WAYPOINT":
                pointType = YMKRequestPointType.waypoint
            default:
                pointType = YMKRequestPointType.waypoint
        }
        return YMKRequestPoint(point: point, type: pointType, pointContext: nil)
    }
}

