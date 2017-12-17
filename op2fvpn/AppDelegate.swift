import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleGetURL(event:reply:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL) )
    }
    
    @objc func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            print("got urlString \(urlString)")
            let urlCo = URLComponents(string: urlString)
            let myAppleScript = """
            tell application "iTerm2"
            create window with default profile command "echo \(urlCo?.host ?? "invalid") && sleep 200"
            end tell
            """
           

            let proc = Process()
            proc.launchPath = "/usr/bin/env"
            proc.arguments = ["/usr/bin/osascript", "-"]
            proc.launch()

        }
    }
    
    
}


