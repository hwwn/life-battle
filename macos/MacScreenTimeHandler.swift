import Cocoa
import FlutterMacOS

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
        case socialMedia = "社交媒体"
        case other = "其他"

        // 判断类别是否有益
        var isBeneficial: Bool {
            switch self {
            case .productivity, .development, .education:
                return true
            case .entertainment, .game, .socialMedia:
                return false
            case .browser, .social, .other:
                return true  // 可以根据需求调整
            }
        }

        // 获取对应的宠物/怪兽类型
        var creatureType: String {
            switch self {
            case .productivity:
                return "勤劳的小蜜蜂"
            case .development:
                return "智慧的猫头鹰"
            case .education:
                return "博学的海豚"
            case .entertainment:
                return "懒惰的树懒"
            case .game:
                return "贪玩的小恶魔"
            case .browser:
                return "探索的狐狸"
            case .social:
                return "热情的小狗"
            case .socialMedia:
                return "沉迷的海妖"
            case .other:
                return "神秘的变色龙"
            }
        }
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

        // 生产力工具
        "com.apple.finder": .productivity,
        "com.apple.mail": .productivity,
        "com.microsoft.Excel": .productivity,
        "com.microsoft.Word": .productivity,
        "com.microsoft.Powerpoint": .productivity,
        "com.apple.iWork.Pages": .productivity,
        "com.apple.iWork.Numbers": .productivity,
        "com.apple.iWork.Keynote": .productivity,

        // 社交应用
        "com.tencent.xinWeChat": .social,
        "com.apple.iChat": .social,
        "com.apple.FaceTime": .social,
        "com.skype.skype": .social,
        "com.slack.Slack": .social,
        "com.discord.Discord": .social,
        "com.apple.Messages": .social,
        "com.tencent.QQ": .social,
        "com.tencent.WeChat": .social,
        "com.tencent.tim": .social,

        // 游戏
        "com.steam.Steam": .game,
        "com.epicgames.EpicGamesLauncher": .game,
        "com.blizzard.BattleNet": .game,

        // 娱乐应用 （有害）
        "com.apple.TV": .entertainment,
        "com.spotify.client": .entertainment,
        "com.netflix.Netflix": .entertainment,
        "com.bilibili.player": .entertainment,
        "com.tencent.QQMusic": .entertainment,
        "com.neteasemusic.163music": .entertainment,

        // 社交媒体应用（有害）
        "com.instagram.Instagram": .socialMedia,
        "com.zhiliaoapp.musically": .socialMedia,  // TikTok/抖音
        "com.xingin.xiaohongshu": .socialMedia,  // 小红书

        // 教育
        "com.apple.iBooks": .education,
        "com.readdle.PDFExpert-Mac": .education,
        "com.adobe.Reader": .education,
        "org.zotero.zotero": .education,
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
                "minutes": minutes,
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

                print(
                    "App: \(lastApp), Category: \(lastCategory.rawValue), Duration: \(duration) seconds"
                )
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
