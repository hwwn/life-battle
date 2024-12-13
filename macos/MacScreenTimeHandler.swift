import FlutterMacOS
import Cocoa

class MacScreenTimeHandler: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "app/screen_time",
            binaryMessenger: registrar.messenger)
        let instance = MacScreenTimeHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // 定义应用类别枚举
    enum AppCategory: String {
        case productivity = "生产力工具"
        case development = "开发工具"
        case browser = "浏览器"
        case social = "社交"
        case entertainment = "娱乐"
        case game = "游戏"
        case education = "教育"
        case other = "其他"
    }
    
    // 应用 ID 到类别的映射
    private let appCategories: [String: AppCategory] = [
        // 开发工具
        "com.microsoft.VSCode": .development,
        "com.apple.dt.Xcode": .development,
        "com.sublimetext.4": .development,
        "com.jetbrains.intellij": .development,
        "com.cursor.Cursor": .development,
        "com.DanPristupov.Fork": .development,
        
        // 浏览器
        "com.google.Chrome": .browser,
        "com.microsoft.Edge": .browser,
        "com.apple.Safari": .browser,
        "org.mozilla.firefox": .browser,
        
        // 社交软件
        "com.tencent.xinWeChat": .social,
        "com.apple.iChat": .social,
        "com.slack.Slack": .social,
        
        // 生产力工具
        "com.apple.Notes": .productivity,
        "com.microsoft.Excel": .productivity,
        "com.microsoft.Word": .productivity,
        "com.apple.mail": .productivity,
        "com.apple.WebKit.WebContent": .productivity,
        
        // 娱乐
        "com.spotify.client": .entertainment,
        "com.apple.Music": .entertainment,
        "com.apple.TV": .entertainment,
        
        // 游戏
        "com.steam.Steam": .game
    ]
    
    private var appUsage: [String: TimeInterval] = [:]
    private var lastAppName: String?
    private var lastSwitchTime: Date = Date()
    private var categoryUsage: [AppCategory: TimeInterval] = [:]
    
    private func getAppCategory(_ bundleIdentifier: String?) -> AppCategory {
        guard let bundleId = bundleIdentifier else { return .other }
        return appCategories[bundleId] ?? .other
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getScreenTime" {
            handleScreenTimeRequest(result: result)
        }
    }
    
    private func handleScreenTimeRequest(result: @escaping FlutterResult) {
        updateAppUsage()
        
        // 创建包含应用信息和类别的数据结构
        var usageData: [String: Any] = [:]
        
        // 应用使用时间
        let appUsageMinutes = appUsage.mapValues { Int($0 / 60) }
        usageData["apps"] = appUsageMinutes
        
        // 类别使用时间
        let categoryUsageMinutes = categoryUsage.mapValues { Int($0 / 60) }
        let categoryData = categoryUsageMinutes.map { (category, minutes) in
            return [
                "category": category.rawValue,
                "minutes": minutes
            ]
        }
        usageData["categories"] = categoryData
        
        // 添加调试输出
        print("发送数据到 Flutter:")
        print("应用使用时间: \(appUsageMinutes)")
        print("类别使用时间: \(categoryData)")
        
        result(usageData)
    }
    
    private func updateAppUsage() {
        let workspace = NSWorkspace.shared
        if let activeApp = workspace.frontmostApplication {
            let currentAppName = activeApp.localizedName ?? "Unknown"
            let now = Date()
            
            if let lastApp = lastAppName {
                let duration = now.timeIntervalSince(lastSwitchTime)
                appUsage[lastApp, default: 0] += duration
                
                // 更新类别使用时间
                let lastCategory = getAppCategory(activeApp.bundleIdentifier)
                categoryUsage[lastCategory, default: 0] += duration
                
                print("App: \(lastApp), Category: \(lastCategory.rawValue), Duration: \(duration) seconds")
            }
            
            lastAppName = currentAppName
            lastSwitchTime = now
        }
    }
    
    override init() {
        super.init()
        print("开始初始化定时器")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print("定时器触发")
            self.updateAppUsage()
        }
        print("定时器初始化完成")
    }
}
