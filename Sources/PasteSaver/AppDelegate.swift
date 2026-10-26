import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let pasteboard = PasteboardService()
    private let popover = NSPopover()
    private var statusItem: NSStatusItem?

    private lazy var store = HistoryStore(pasteboard: pasteboard)
    private lazy var monitor = ClipboardMonitor(service: pasteboard) { [weak self] content, sourceApp in
        self?.store.capture(content, sourceApp: sourceApp)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        LaunchAtLogin.registerOnFirstRun()
        configureStatusItem()
        configurePopover()
        monitor.start()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = makeStatusImage()
            button.target = self
            button.action = #selector(handleStatusItemClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
    }

    private func makeStatusImage() -> NSImage? {
        if let logo = Branding.statusBarImage() {
            return logo
        }
        let fallback = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "PasteSaver")
        fallback?.isTemplate = true
        return fallback
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 380, height: 520)
    }

    @objc private func handleStatusItemClick() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem?.button else { return }

        let rootView = ContentView(
            store: store,
            onSelect: { [weak self] item in self?.select(item) },
            onQuit: { NSApp.terminate(nil) }
        )
        popover.contentViewController = NSHostingController(rootView: rootView)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        NSApp.activate(ignoringOtherApps: true)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func select(_ item: ClipboardItem) {
        store.copyToPasteboard(item)
        popover.performClose(nil)
    }

    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(
            withTitle: "Quit PasteSaver",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
}
