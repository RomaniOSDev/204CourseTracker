//
//  CourseFormViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

enum CourseFormMode {
    case add
    case edit(UUID)
}

struct DraftLesson: Identifiable, Equatable {
    let id: UUID
    var title: String
    var durationText: String
    var isCompleted: Bool
    var order: Int

    init(from lesson: Lesson) {
        id = lesson.id
        title = lesson.title
        durationText = lesson.duration.map(String.init) ?? ""
        isCompleted = lesson.isCompleted
        order = lesson.order
    }

    init(order: Int) {
        id = UUID()
        title = ""
        durationText = ""
        isCompleted = false
        self.order = order
    }

    func toLesson() -> Lesson? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let duration = Int(durationText.trimmingCharacters(in: .whitespacesAndNewlines))
        return Lesson(
            id: id,
            title: trimmed,
            duration: duration,
            isCompleted: isCompleted,
            order: order
        )
    }
}

@MainActor
final class CourseFormViewModel: ObservableObject {
    @Published var title = ""
    @Published var descriptionText = ""
    @Published var platform: Platform = .coursera
    @Published var category: CourseCategory = .programming
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @Published var includeStartDate = false
    @Published var includeEndDate = false
    @Published var isFavorite = false
    @Published var draftLessons: [DraftLesson] = []
    @Published var validationMessage: String?
    @Published var didSave = false

    let mode: CourseFormMode
    private let store: CourseStore
    private var existingCourse: Course?

    var navigationTitle: String {
        switch mode {
        case .add: return "New Course"
        case .edit: return "Edit Course"
        }
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(store: CourseStore, mode: CourseFormMode) {
        self.store = store
        self.mode = mode

        if case .edit(let id) = mode, let course = store.course(id: id) {
            existingCourse = course
            title = course.title
            descriptionText = course.description ?? ""
            platform = course.platform
            category = course.category
            isFavorite = course.isFavorite
            if let start = course.startDate {
                includeStartDate = true
                startDate = start
            }
            if let end = course.endDate {
                includeEndDate = true
                endDate = end
            }
            draftLessons = course.sortedLessons.map(DraftLesson.init(from:))
        }
    }

    func addLesson() {
        draftLessons.append(DraftLesson(order: draftLessons.count))
    }

    func removeLesson(_ lesson: DraftLesson) {
        draftLessons.removeAll { $0.id == lesson.id }
        reindexLessons()
    }

    func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationMessage = "Title is required."
            return
        }

        let lessons = draftLessons.enumerated().compactMap { index, draft -> Lesson? in
            var lesson = draft.toLesson()
            lesson?.order = index
            return lesson
        }

        var course = existingCourse ?? Course(title: trimmedTitle)
        course.title = trimmedTitle
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        course.description = trimmedDescription.isEmpty ? nil : trimmedDescription
        course.platform = platform
        course.category = category
        course.startDate = includeStartDate ? startDate : nil
        course.endDate = includeEndDate ? endDate : nil
        course.isFavorite = isFavorite
        course.lessons = lessons
        course.syncCompletionFromLessons()

        switch mode {
        case .add:
            store.addCourse(course)
        case .edit:
            store.updateCourse(course)
        }

        validationMessage = nil
        didSave = true
    }

    private func reindexLessons() {
        for index in draftLessons.indices {
            draftLessons[index].order = index
        }
    }
}
