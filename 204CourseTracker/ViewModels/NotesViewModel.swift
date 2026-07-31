//
//  NotesViewModel.swift
//  204CourseTracker
//

import Foundation
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var showAddSheet = false
    @Published var newTitle = ""
    @Published var newContent = ""
    @Published var validationMessage: String?

    let courseId: UUID
    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    var courseTitle: String {
        store.course(id: courseId)?.title ?? "Course"
    }

    init(store: CourseStore, courseId: UUID) {
        self.store = store
        self.courseId = courseId

        store.$notes
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
        refresh()
    }

    func openAddSheet() {
        newTitle = ""
        newContent = ""
        validationMessage = nil
        showAddSheet = true
    }

    func addNote() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = newContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            validationMessage = "Title is required."
            return
        }
        guard !content.isEmpty else {
            validationMessage = "Content is required."
            return
        }

        let note = Note(courseId: courseId, title: title, content: content)
        store.addNote(note)
        showAddSheet = false
    }

    func delete(at offsets: IndexSet) {
        let ids = offsets.map { notes[$0].id }
        ids.forEach { store.deleteNote(id: $0) }
    }

    func delete(_ note: Note) {
        store.deleteNote(id: note.id)
    }

    func createFlashcards() {
        store.createFlashcards(fromNotes: courseId)
    }

    private func refresh() {
        notes = store.notes(for: courseId)
    }
}
