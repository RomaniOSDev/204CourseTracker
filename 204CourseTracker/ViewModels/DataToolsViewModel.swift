//
//  DataToolsViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
final class DataToolsViewModel: ObservableObject {
    @Published var selectedFormat: ExportFormat = .json
    @Published var exportURL: URL?
    @Published var statusMessage: String?
    @Published var showImporter = false
    @Published var showExporter = false
    @Published var showDocumentBackup = false

    private let store: CourseStore

    init(store: CourseStore) {
        self.store = store
    }

    var importTypes: [UTType] {
        [.json, .plainText, UTType(filenameExtension: "md") ?? .text].compactMap { $0 }
    }

    func prepareExport() {
        do {
            let backup = ExportImportService.makeBackup(from: store.makeBackup())
            let data = try ExportImportService.exportData(backup, format: selectedFormat)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("learning-export-\(Int(Date().timeIntervalSince1970)).\(selectedFormat.fileExtension)")
            try data.write(to: url, options: .atomic)
            exportURL = url
            showExporter = true
            statusMessage = "Export ready (\(selectedFormat.displayName))."
        } catch {
            statusMessage = "Export failed."
        }
    }

    func importFile(url: URL) {
        do {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            if selectedFormat == .json || url.pathExtension.lowercased() == "json" {
                let backup = try ExportImportService.importJSON(data)
                store.replaceAll(with: backup)
                statusMessage = "Backup imported successfully."
            } else {
                statusMessage = "Only JSON backups can be imported."
            }
        } catch {
            statusMessage = "Import failed."
        }
    }

    func writeICloudOrFilesBackup() {
        prepareExport()
        showDocumentBackup = exportURL != nil
    }
}
