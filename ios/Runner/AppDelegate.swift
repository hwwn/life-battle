import UIKit
import Flutter
import DeviceActivity
import FamilyControls

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // 注册 ScreenTimeHandler
        let controller = window?.rootViewController as! FlutterViewController
        let screenTimeChannel = FlutterMethodChannel(
            name: "app/screen_time",
            binaryMessenger: controller.binaryMessenger
        )
        
        let screenTimeHandler = ScreenTimeHandler()
        screenTimeChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            screenTimeHandler.handle(call, result: result)
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
