//
//  ScreenSnapApp.swift
//  ScreenSnap
//
//  Created by Eric COLOGNI on 03/11/2025.
//

import SwiftUI
import AppKit

@main
struct ScreenSnapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var screenshotService: ScreenshotService?
    var windowCaptureService: WindowCaptureService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - Menu bar app only
        NSApp.setActivationPolicy(.accessory)

        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: "ScreenSnap")
            button.action = #selector(showMenu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Initialize services
        screenshotService = ScreenshotService()
        windowCaptureService = WindowCaptureService()

        // Setup menu
        setupMenu()

        // Request permissions
        requestScreenRecordingPermission()
    }

    @objc func showMenu() {
        guard let button = statusItem?.button else { return }

        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            // Right click - show menu
            statusItem?.menu = createMenu()
            button.performClick(nil)
            statusItem?.menu = nil
        } else {
            // Left click - show popover
            togglePopover()
        }
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover, popover.isShown {
            popover.performClose(nil)
            self.popover = nil
        } else {
            showPopover(button)
        }
    }

    func showPopover(_ sender: NSButton) {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 200)
        popover.behavior = .transient
        popover.animates = true

        let hostingController = NSHostingController(rootView: MenuBarPopoverView())
        popover.contentViewController = hostingController

        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        self.popover = popover

        NSApp.activate(ignoringOtherApps: true)
    }

    func setupMenu() {
        // Menu is created dynamically on right-click
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Capture d'écran", action: #selector(takeScreenshot), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Capturer une fenêtre", action: #selector(captureWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Préférences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quitter", action: #selector(quit), keyEquivalent: "q"))

        return menu
    }

    @objc func takeScreenshot() {
        screenshotService?.captureScreenshot()
    }

    @objc func captureWindow() {
        windowCaptureService?.showWindowSelector()
    }

    @objc func openPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        if #available(macOS 14, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    func requestScreenRecordingPermission() {
        if #available(macOS 10.15, *) {
            CGRequestScreenCaptureAccess()
        }
    }
}
