//
//  DataToolsView.swift
//  204CourseTracker
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DataToolsView: View {
    @StateObject private var viewModel: DataToolsViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: DataToolsViewModel(store: store))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Export, share, and restore your offline library.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Export Format")
                        Picker("Format", selection: $viewModel.selectedFormat) {
                            ForEach(ExportFormat.allCases) { format in
                                Text(format.displayName).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)

                        Button("Export & Share") { viewModel.prepareExport() }
                            .buttonStyle(PrimaryButtonStyle())

                        Button("Backup to Files / iCloud Drive") {
                            viewModel.writeICloudOrFilesBackup()
                        }
                        .buttonStyle(PrimaryButtonStyle(filled: false))
                    }
                    .softCard()

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Import JSON Backup")
                        Text("CSV and Markdown are export-only. Restore requires a JSON backup.")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Button("Choose Backup File") { viewModel.showImporter = true }
                            .buttonStyle(PrimaryButtonStyle(filled: false))
                    }
                    .softCard()

                    if let status = viewModel.statusMessage {
                        Text(status)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppColors.textSecondary)
                            .softCard(padding: 12, radius: AppRadius.sm)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Data & Backup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fileImporter(
            isPresented: $viewModel.showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                viewModel.importFile(url: url)
            }
        }
        .sheet(isPresented: $viewModel.showExporter) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url])
            }
        }
        .fileExporter(
            isPresented: $viewModel.showDocumentBackup,
            document: ExportDocument(url: viewModel.exportURL),
            contentType: contentType(for: viewModel.selectedFormat),
            defaultFilename: "learning-backup"
        ) { result in
            switch result {
            case .success:
                viewModel.statusMessage = "Backup saved to Files / iCloud."
            case .failure:
                viewModel.statusMessage = "Could not save backup."
            }
        }
    }

    private func contentType(for format: ExportFormat) -> UTType {
        switch format {
        case .json: return .json
        case .csv: return .commaSeparatedText
        case .markdown: return UTType(filenameExtension: "md") ?? .plainText
        }
    }
}

private struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .commaSeparatedText, .plainText] }

    var data: Data

    init(url: URL?) {
        if let url, let data = try? Data(contentsOf: url) {
            self.data = data
        } else {
            self.data = Data()
        }
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
