import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationDidFinishLaunching(_ notification: Notification) {
        if let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController {
            MacScreenTimeHandler.register(with: flutterViewController.registrar(forPlugin: "MacScreenTimeHandler"))
        }
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
