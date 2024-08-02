import Cocoa
import UniformTypeIdentifiers

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var urls: [String] = []
    var apps: [String] = []
    var files: [String] = []

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
        for (index, urlString) in urls.enumerated() {
            let menuItem = NSMenuItem(title: urlString, action: nil, keyEquivalent: "")
            let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteURL(_:)), keyEquivalent: "")
            deleteItem.tag = index
            submenu.addItem(menuItem)
            submenu.addItem(deleteItem)
        }

        // Add Apps to the submenu
        for (index, app) in apps.enumerated() {
            let menuItem = NSMenuItem(title: app, action: nil, keyEquivalent: "")
            let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteApp(_:)), keyEquivalent: "")
            deleteItem.tag = index
            submenu.addItem(menuItem)
            submenu.addItem(deleteItem)
        }

        // Add Files to the submenu
        for (index, file) in files.enumerated() {
            let menuItem = NSMenuItem(title: file, action: nil, keyEquivalent: "")
            let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteFile(_:)), keyEquivalent: "")
            deleteItem.tag = index
            submenu.addItem(menuItem)
            submenu.addItem(deleteItem)
        }

        return submenu
    }

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

    @objc func openFile(_ sender: NSMenuItem) {
        let fileUrl = URL(fileURLWithPath: sender.title)
        NSWorkspace.shared.open(fileUrl)
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
        
        // Set the default directory to the Applications folder
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        
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


    @objc func addFile() {
        let openPanel = NSOpenPanel()
        openPanel.message = "Select a file to add"
        openPanel.prompt = "Add"
        openPanel.allowedContentTypes = [UTType.content] // This allows selecting any content type
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.begin { (result) in
            if result == .OK {
                if let url = openPanel.url {
                    self.files.append(url.path) // Assuming 'files' is the array to store file paths
                    // Update the menu
                    self.updateMenu()
                }
            }
        }
    }

    @objc func deleteURL(_ sender: NSMenuItem) {
        urls.remove(at: sender.tag)
        updateMenu()
    }

    @objc func deleteApp(_ sender: NSMenuItem) {
        apps.remove(at: sender.tag)
        updateMenu()
    }

    @objc func deleteFile(_ sender: NSMenuItem) {
        files.remove(at: sender.tag)
        updateMenu()
    }

    func updateMenu() {
        let menu = NSMenu()

        // Add the main item to open all URLs and apps
        menu.addItem(NSMenuItem(title: "Open All URLs and Apps", action: #selector(openUrlsAndApps), keyEquivalent: "O"))

        // Add the submenu for individual URLs, apps, and files
        let openSubmenuItem = NSMenuItem(title: "Delete Individual URLs, Apps, and Files", action: nil, keyEquivalent: "")
        menu.addItem(openSubmenuItem)
        menu.setSubmenu(createOpenSubmenu(), for: openSubmenuItem)

        // Add other menu items
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Add URL", action: #selector(addURL), keyEquivalent: "U"))
        menu.addItem(NSMenuItem(title: "Add App", action: #selector(addApp), keyEquivalent: "A"))
        menu.addItem(NSMenuItem(title: "Add File", action: #selector(addFile), keyEquivalent: "F"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))

        // Assign the menu to the status item
        statusItem?.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
