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
        activate()
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
            NSColor.black.setStroke()
            NSColor.black.setFill()

            if active {
                // Tube diagonal (snorting)
                let tube = NSBezierPath()
                tube.move(to: NSPoint(x: 6, y: 4))
                tube.line(to: NSPoint(x: 12, y: 14))
                tube.lineWidth = 2.5
                tube.lineCapStyle = .round
                tube.stroke()

                // Powder lines
                let line1 = NSBezierPath()
                line1.move(to: NSPoint(x: 2, y: 4))
                line1.line(to: NSPoint(x: 6, y: 4))
                line1.lineWidth = 1.5
                line1.lineCapStyle = .round
                line1.stroke()

                let line2 = NSBezierPath()
                line2.move(to: NSPoint(x: 2, y: 1.5))
                line2.line(to: NSPoint(x: 8, y: 1.5))
                line2.lineWidth = 1.5
                line2.lineCapStyle = .round
                line2.stroke()

                // Particles
                NSBezierPath(ovalIn: NSRect(x: 5, y: 6, width: 1.5, height: 1.5)).fill()
                NSBezierPath(ovalIn: NSRect(x: 7, y: 8, width: 1, height: 1)).fill()
            } else {
                // Tube lying flat (inactive)
                let tube = NSBezierPath()
                tube.move(to: NSPoint(x: 4, y: 9))
                tube.line(to: NSPoint(x: 14, y: 9))
                tube.lineWidth = 2.5
                tube.lineCapStyle = .round
                tube.stroke()
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
