//
//  CourseDetailViewModel.swift
//  204CourseTracker
//

import Foundation
import Combine

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published private(set) var course: Course?
    @Published var showDeleteConfirmation = false
    @Published var didDelete = false
    @Published var showReflection = false
    @Published var reflectionMood: MoodLevel = .good
    @Published var reflectionEnergy: EnergyLevel = .medium
    @Published var reflectionNote = ""

    let courseId: UUID
    private let store: CourseStore
    private var pendingReflectionLessonId: UUID?
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore, courseId: UUID) {
        self.store = store
        self.courseId = courseId

        store.$courses
            .receive(on: RunLoop.main)
            .sink { [weak self] courses in
                self?.course = courses.first { $0.id == courseId }
            }
            .store(in: &cancellables)
    }

    func toggleLesson(_ lessonId: UUID) {
        let becameCompleted = store.toggleLesson(courseId: courseId, lessonId: lessonId)
        if becameCompleted {
            pendingReflectionLessonId = lessonId
            reflectionMood = .good
            reflectionEnergy = .medium
            reflectionNote = ""
            showReflection = true
        }
    }

    func saveReflection() {
        guard let lessonId = pendingReflectionLessonId else {
            showReflection = false
            return
        }
        let note = reflectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        store.addReflection(
            LessonReflection(
                id: UUID(),
                courseId: courseId,
                lessonId: lessonId,
                mood: reflectionMood,
                energy: reflectionEnergy,
                note: note.isEmpty ? nil : note,
                createdAt: Date()
            )
        )
        pendingReflectionLessonId = nil
        showReflection = false
    }

    func skipReflection() {
        pendingReflectionLessonId = nil
        showReflection = false
    }

    func deleteCourse() {
        store.deleteCourse(id: courseId)
        didDelete = true
    }
}
