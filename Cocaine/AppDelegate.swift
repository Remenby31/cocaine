import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var caffeineProcess: Process?
    private var isActive = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem.button else { return }
        button.action = #selector(statusBarClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.target = self
        updateIcon()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if isActive {
            deactivate()
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        let statusText = isActive ? "Active — lid close won't sleep" : "Inactive"
        let statusMenuItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())

        let toggleTitle = isActive ? "Deactivate" : "Activate"
        menu.addItem(NSMenuItem(title: toggleTitle, action: #selector(toggleSleep), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let loginItem = NSMenuItem(title: "Start at Login", action: #selector(toggleLoginItem(_:)), keyEquivalent: "")
        loginItem.state = isLoginItemEnabled() ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func statusBarClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggleSleep()
        }
    }

    @objc private func toggleSleep() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }

    private func activate() {
        runPrivileged("/usr/bin/pmset", arguments: ["-a", "disablesleep", "1"])

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-di"]
        try? process.run()
        caffeineProcess = process

        isActive = true
        updateIcon()
    }

    private func deactivate() {
        caffeineProcess?.terminate()
        caffeineProcess = nil

        runPrivileged("/usr/bin/pmset", arguments: ["-a", "disablesleep", "0"])

        isActive = false
        updateIcon()
    }

    private func runPrivileged(_ path: String, arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = [path] + arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        let icon = makeIcon(active: isActive)
        icon.isTemplate = true
        button.image = icon
        button.toolTip = isActive ? "Cocaine: Active" : "Cocaine: Inactive"
    }

    private func makeIcon(active: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSGraphicsContext.current?.cgContext.setLineWidth(1.5)
            NSColor.black.setStroke()

            // Nose shape (triangle/line)
            let nosePath = NSBezierPath()
            nosePath.move(to: NSPoint(x: 5, y: 4))
            nosePath.line(to: NSPoint(x: 9, y: 14))
            nosePath.line(to: NSPoint(x: 13, y: 4))
            nosePath.stroke()

            if active {
                // "Powder lines" when active
                NSColor.black.setFill()
                let line1 = NSBezierPath()
                line1.move(to: NSPoint(x: 2, y: 2))
                line1.line(to: NSPoint(x: 7, y: 2))
                line1.lineWidth = 2.0
                line1.stroke()

                let line2 = NSBezierPath()
                line2.move(to: NSPoint(x: 10, y: 2))
                line2.line(to: NSPoint(x: 16, y: 2))
                line2.lineWidth = 2.0
                line2.stroke()
            }

            return true
        }
        image.isTemplate = true
        return image
    }

    @objc private func toggleLoginItem(_ sender: NSMenuItem) {
        if isLoginItemEnabled() {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
        sender.state = isLoginItemEnabled() ? .on : .off
    }

    private func isLoginItemEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }

    @objc private func quit() {
        if isActive { deactivate() }
        NSApp.terminate(nil)
    }
}
