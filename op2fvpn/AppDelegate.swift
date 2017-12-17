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
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    @objc func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            print("got urlString \(urlString)")
            let answer = dialogOKCancel(question: "Ok?", text: "Choose your answer.")

            let urlCo = URLComponents(string: urlString)
            let myAppleScript = """
            tell application "iTerm2"
            create window with default profile

                tell current window
                    tell current session
            write text "sudo exec openfortivpn \(urlCo?.host ?? "not supplied"):\(urlCo?.port ?? 0) -u \(urlCo?.user ?? "not supplied") -p \(urlCo?.password ?? "not supplied")"
                    end tell
                end tell
            end tell
            """
           
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: myAppleScript) {
                if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                    &error) {
                    print(output.stringValue)
                } else if (error != nil) {
                    print("error: \(error)")
                }
            }
        }
    }
    
    
}


