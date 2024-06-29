import Cocoa
import UniformTypeIdentifiers

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var urls: [String] = []
    var apps: [String] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = "OneClick"
        }

        // Create the menu
        updateMenu()
    }

    func createOpenSubmenu() -> NSMenu {
        let submenu = NSMenu()

        // Add URLs to the submenu
        for urlString in urls {
            submenu.addItem(NSMenuItem(title: urlString, action: #selector(openURL(_:)), keyEquivalent: ""))
        }

        // Add Apps to the submenu
        for app in apps {
            submenu.addItem(NSMenuItem(title: app, action: #selector(openApp(_:)), keyEquivalent: ""))
        }

        return submenu
    }
//    @objc func openURL(_ sender: NSMenuItem) {
//         if let url = URL(string: sender.title) {
//             NSWorkspace.shared.open(url)
//         }
//     }

    @objc func openURL(_ sender: NSMenuItem) {
        if let url = URL(string: sender.title) {
            openInNewTab(url: url)
     }
    }
    func openInNewTab(url: URL) {
        let script = """
        tell application "Safari"
            activate
            set newWindow to (make new document)
            tell newWindow
                set URL to "\(url.absoluteString)"
            end tell
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
        }
        
        if let error = error {
            print("Error: \(error)")
        }
    }
    
    @objc func openApp(_ sender: NSMenuItem) {
        if let appUrl = URL(string: "file://\(sender.title)") {
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: appUrl, configuration: configuration, completionHandler: nil)
        }
    }

    @objc func openUrlsAndApps() {
        // Open URLs
        for urlString in urls {
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }

        // Open Applications
        for app in apps {
            if let appUrl = URL(string: "file://\(app)") {
                let configuration = NSWorkspace.OpenConfiguration()
                NSWorkspace.shared.openApplication(at: appUrl, configuration: configuration, completionHandler: nil)
            }
        }
    }

    @objc func addURL() {
        let alert = NSAlert()
        alert.messageText = "Add URL"
        alert.informativeText = "Enter the URL to open:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input

        let response = alert.runModal()
        if response == .alertFirstButtonReturn, let url = input.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urls.append(url)
            // Update the menu
            updateMenu()
        }
    }

    @objc func addApp() {
        let openPanel = NSOpenPanel()
        openPanel.message = "Select an application to add"
        openPanel.prompt = "Add"
        openPanel.allowedContentTypes = [UTType.application]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.begin { (result) in
            if result == .OK {
                if let url = openPanel.url {
                    self.apps.append(url.path)
                    // Update the menu
                    self.updateMenu()
                }
            }
        }
    }

    func updateMenu() {
        let menu = NSMenu()

        // Add the main item to open all URLs and apps
        menu.addItem(NSMenuItem(title: "Open All URLs and Apps", action: #selector(openUrlsAndApps), keyEquivalent: "O"))

        // Add the submenu for individual URLs and apps
        let openSubmenuItem = NSMenuItem(title: "Open Individual URLs and Apps", action: nil, keyEquivalent: "")
        menu.addItem(openSubmenuItem)
        menu.setSubmenu(createOpenSubmenu(), for: openSubmenuItem)

        // Add other menu items
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Add URL", action: #selector(addURL), keyEquivalent: "U"))
        menu.addItem(NSMenuItem(title: "Add App", action: #selector(addApp), keyEquivalent: "A"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))

        // Assign the menu to the status item
        statusItem?.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
