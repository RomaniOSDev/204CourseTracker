//
//  TemplatesViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class TemplatesViewModel: ObservableObject {
    @Published var statusMessage: String?

    let templates = TemplateService.all
    private let store: CourseStore

    init(store: CourseStore) {
        self.store = store
    }

    func apply(_ template: CourseTemplate) {
        store.applyTemplate(template)
        statusMessage = "“\(template.title)” added to your library."
    }
}
