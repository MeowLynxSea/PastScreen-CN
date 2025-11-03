//
//  ScreenshotService.swift
//  ScreenSnap
//
//  Screenshot capture service with Liquid Glass selection UI
//

import Foundation
import AppKit
import CoreGraphics
import SwiftUI
import UserNotifications

class ScreenshotService: NSObject {
    private var selectionWindow: SelectionWindow?

    override init() {
        super.init()
        setupNotificationObservers()
    }

    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenshotRequest),
            name: .screenshotRequested,
            object: nil
        )
    }

    @objc func handleScreenshotRequest() {
        captureScreenshot()
    }

    func captureScreenshot() {
        // Close any existing selection window
        selectionWindow?.close()

        // Create and show new selection window
        selectionWindow = SelectionWindow { [weak self] selectedRect in
            self?.performCapture(rect: selectedRect)
        }
        selectionWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func performCapture(rect: CGRect) {
        guard let cgImage = captureScreenRegion(rect: rect) else {
            print("Failed to capture screen region")
            return
        }

        let nsImage = NSImage(cgImage: cgImage, size: rect.size)

        // Play sound if enabled
        if AppSettings.shared.playSoundOnCapture {
            NSSound(named: "Pop")?.play()
        }

        // Copy to clipboard if enabled
        if AppSettings.shared.copyToClipboard {
            copyToClipboard(image: nsImage)
        }

        // Save to file if enabled
        if AppSettings.shared.saveToFile {
            saveToFile(image: nsImage)
        }

        // Show notification
        showNotification()
    }

    private func captureScreenRegion(rect: CGRect) -> CGImage? {
        guard let screenFrame = NSScreen.main?.frame else { return nil }

        // Convert from AppKit coordinates (bottom-left origin) to screen coordinates (top-left origin)
        let flippedRect = CGRect(
            x: rect.origin.x,
            y: screenFrame.height - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )

        let displayID = CGMainDisplayID()
        return CGDisplayCreateImage(displayID, rect: flippedRect)
    }

    private func copyToClipboard(image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }

    private func saveToFile(image: NSImage) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return
        }

        let fileType: NSBitmapImageRep.FileType
        let fileExtension: String

        switch AppSettings.shared.imageFormat {
        case "jpeg":
            fileType = .jpeg
            fileExtension = "jpg"
        default:
            fileType = .png
            fileExtension = "png"
        }

        guard let data = bitmapImage.representation(using: fileType, properties: [:]) else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "Screenshot-\(timestamp).\(fileExtension)"

        AppSettings.shared.ensureFolderExists()
        let filePath = AppSettings.shared.saveFolderPath + filename

        try? data.write(to: URL(fileURLWithPath: filePath))
    }

    private func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ScreenSnap"
        content.body = "Capture d'écran réussie"
        content.sound = nil

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Selection Window

class SelectionWindow: NSWindow {
    private var selectionView: SelectionView?
    private var onSelection: ((CGRect) -> Void)?

    init(onSelection: @escaping (CGRect) -> Void) {
        self.onSelection = onSelection

        // Create window covering all screens
        let mainScreen = NSScreen.main ?? NSScreen.screens[0]
        var combinedFrame = mainScreen.frame

        for screen in NSScreen.screens {
            combinedFrame = combinedFrame.union(screen.frame)
        }

        super.init(
            contentRect: combinedFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.ignoresMouseEvents = false
        self.hasShadow = false

        selectionView = SelectionView(frame: combinedFrame) { [weak self] rect in
            self?.close()
            onSelection(rect)
        }

        if let selectionView = selectionView {
            self.contentView = selectionView
        }
    }
}

// MARK: - Selection View

class SelectionView: NSView {
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?
    private var onSelection: ((CGRect) -> Void)?

    init(frame: NSRect, onSelection: @escaping (CGRect) -> Void) {
        self.onSelection = onSelection
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentPoint = startPoint
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let start = startPoint, let end = currentPoint else { return }

        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )

        if rect.width > 10 && rect.height > 10 {
            onSelection?(rect)
        } else {
            window?.close()
        }
    }

    override func keyDown(with event: NSEvent) {
        // ESC key cancels selection
        if event.keyCode == 53 {
            window?.close()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Dark overlay
        NSColor.black.withAlphaComponent(0.4).setFill()
        bounds.fill()

        guard let start = startPoint, let end = currentPoint else { return }

        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )

        // Clear selected area (cut out)
        NSColor.clear.setFill()
        rect.fill(using: .destinationOut)

        // Selection border with glow effect
        NSGraphicsContext.saveGraphicsState()

        // Outer glow
        let glowPath = NSBezierPath(rect: rect.insetBy(dx: -2, dy: -2))
        NSColor.white.withAlphaComponent(0.3).setStroke()
        glowPath.lineWidth = 4
        glowPath.stroke()

        // Main border
        let borderPath = NSBezierPath(rect: rect)
        NSColor.white.setStroke()
        borderPath.lineWidth = 2
        borderPath.stroke()

        NSGraphicsContext.restoreGraphicsState()

        // Dimension label (if enabled)
        if AppSettings.shared.showDimensionsLabel && rect.width > 50 && rect.height > 50 {
            drawDimensionLabel(rect: rect)
        }
    }

    private func drawDimensionLabel(rect: CGRect) {
        let dimensions = String(format: "%.0f × %.0f", rect.width, rect.height)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let labelSize = dimensions.size(withAttributes: attributes)

        let labelRect = CGRect(
            x: rect.maxX - labelSize.width - 12,
            y: rect.maxY + 8,
            width: labelSize.width + 8,
            height: labelSize.height + 6
        )

        // Background
        NSColor.black.withAlphaComponent(0.7).setFill()
        NSBezierPath(roundedRect: labelRect, xRadius: 4, yRadius: 4).fill()

        // Text
        dimensions.draw(
            at: CGPoint(x: labelRect.minX + 4, y: labelRect.minY + 3),
            withAttributes: attributes
        )
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
}
