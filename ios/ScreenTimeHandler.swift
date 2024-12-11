import Flutter
import DeviceActivity
import FamilyControls
import ManagedSettings

class ScreenTimeHandler: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "app/screen_time", binaryMessenger: registrar.messenger())
        let instance = ScreenTimeHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getScreenTime" {
            handleScreenTimeRequest(result: result)
        }
    }
    
    func handleScreenTimeRequest(result: @escaping FlutterResult) {
        let center = AuthorizationCenter.shared
        
        Task {
            do {
                let status = try await center.requestAuthorization(for: .individual)
                
                // 创建时间区间啊
                let now = Date()
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: now)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let schedule = DeviceActivitySchedule(
                    intervalStart: calendar.dateComponents([.hour, .minute], from: startOfDay),
                    intervalEnd: calendar.dateComponents([.hour, .minute], from: endOfDay),
                    repeats: true 
                )
                
                // 获取应用使用数据
                let deviceActivityCenter = DeviceActivityCenter()
                
                var usageData: [String: Int] = [:]
                
                // 注意：这里需要实际实现数据收集逻辑
                // 由于 iOS 15 的限制，我们可能需要使用其他 API
                // 这里只是示例数据
                usageData = [
                    "com.example.app1": 30,  // 30分钟
                    "com.example.app2": 45,  // 45分钟
                ]
                
                result(usageData)
            } catch {
                result(FlutterError(code: "FAILED",
                                  message: "Failed to get screen time",
                                  details: error.localizedDescription))
            }
        }
    }
}
