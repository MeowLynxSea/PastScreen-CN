//
//  AppSettings.swift
//  ScreenSnap
//
//  Settings management with UserDefaults persistence
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("copyToClipboard") var copyToClipboard: Bool = true
    @AppStorage("saveToFile") var saveToFile: Bool = false
    @AppStorage("saveFolderPath") var saveFolderPath: String = NSTemporaryDirectory() + "ScreenSnap/"
    @AppStorage("imageFormat") var imageFormat: String = "png"
    @AppStorage("playSoundOnCapture") var playSoundOnCapture: Bool = true
    @AppStorage("showDimensionsLabel") var showDimensionsLabel: Bool = true
    @AppStorage("enableAnnotations") var enableAnnotations: Bool = true

    private init() {
        ensureFolderExists()
    }

    func ensureFolderExists() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: saveFolderPath) {
            try? fileManager.createDirectory(atPath: saveFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func selectFolder() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Sélectionner"

        if panel.runModal() == .OK {
            if let url = panel.url {
                return url.path + "/"
            }
        }
        return nil
    }

    func clearSaveFolder() {
        let fileManager = FileManager.default
        guard let items = try? fileManager.contentsOfDirectory(atPath: saveFolderPath) else { return }

        for item in items {
            let itemPath = saveFolderPath + item
            try? fileManager.removeItem(atPath: itemPath)
        }
    }
}
