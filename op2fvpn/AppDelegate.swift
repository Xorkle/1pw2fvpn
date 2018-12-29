import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func checkAccess() -> Bool{
        //get the value for accesibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        //set the options: false means it wont ask
        //true means it will popup and ask
        let options = [checkOptPrompt: true]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }
    
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
    func invalid(text: String) -> Void {
        activate()
        dialogOKCancel(question: "A \(text) is required", text: "Please supply a \(text) parameter")
        NSApp.terminate(self)

    }
    
    
    @objc func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if (!checkAccess()) {
            dialogOKCancel(question: "Accessbility access is required", text: "Please grant.")
            NSApp.terminate(self)
        }
        var user, password, host, port, cert : String
        user = ""; password = ""; host = ""; port = ""; cert = ""

        let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue

        
        let urlCo = URLComponents(string: urlString!)
        
        if let user2: String = urlCo?.user {
            user =  user2
        } else {
            invalid(text: "user")
        }

        if let port2: Int = urlCo?.port {
            port =  String(port2)
        } else {
            invalid(text: "port")
        }
       
        if let password2: String = urlCo?.password {
            password = password2
        } else {
            invalid(text: "password")
        }
        
        if let host2: String = urlCo?.host {
            host =  host2
        } else {
            invalid(text: "host")
        }
        
        if let queryItems = urlCo?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "cert" {
                    if let cert2: String = queryItem.value {
                        cert = cert2
                    } else {
                     invalid(text: "cert")
                    }
                }
            }
        } else {
            invalid(text: "cert")
        }

       

        let myAppleScript = """
          tell application "iTerm2"
          create window with default profile

          tell current window
          tell current session
          write text "sudo openfortivpn  --trusted-cert '\(cert)' '\(host):\(port)' -u '\(user)' -p '\(password)'"
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


