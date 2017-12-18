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
        return alert.runModal() == .alertFirstButtonReturn
    }

    func activate() -> Void {
        NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)

    }
    
    @objc func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        var notWell = false
        var user, password, host, port : String
        user = ""; password = ""; host = ""; port = ""

        let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue

        
        let urlCo = URLComponents(string: urlString!)
        
        if let user2: String = urlCo?.user {
            user =  user2
        } else {
            notWell = true
            activate()
            dialogOKCancel(question: "A username is required", text: "Please supply a username parameter")
        }

        if let port2: Int = urlCo?.port {
            port =  String(port2)
        } else {
            notWell = true
            activate()
            dialogOKCancel(question: "A port is required", text: "Please supply a port parameter")
        }
       
        if let password2: String = urlCo?.password {
            password = password2
        } else {
            notWell = true
            activate()
            dialogOKCancel(question: "A password is required", text: "Please supply a password parameter")
        }
        
        if let host2: String = urlCo?.host {
            host =  host2
        } else {
            notWell = true
            activate()
            dialogOKCancel(question: "A hostname is required", text: "Please supply a hostname parameter")
        }

        if (notWell) {
          NSApp.terminate(self)
        }

        let myAppleScript = """
          tell application "iTerm2"
          create window with default profile

          tell current window
          tell current session
          write text "sudo openfortivpn \(host):\(port) -u \(user) -p \(password)"
          end tell
          end tell
          end tell
          """
        print(myAppleScript)
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


