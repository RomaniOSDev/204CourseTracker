//
//  ExamModeViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class ExamModeViewModel: ObservableObject {
    @Published var course: Course?
    @Published var examDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 14)
    @Published var includeExam = false
    @Published var newTopicTitle = ""

    private let store: CourseStore
    private let courseId: UUID
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore, courseId: UUID) {
        self.store = store
        self.courseId = courseId
        store.$courses
            .receive(on: RunLoop.main)
            .sink { [weak self] courses in
                guard let course = courses.first(where: { $0.id == courseId }) else { return }
                self?.course = course
                self?.includeExam = course.examDate != nil
                if let date = course.examDate {
                    self?.examDate = date
                }
            }
            .store(in: &cancellables)
    }

    func saveExamDate() {
        guard var course else { return }
        course.examDate = includeExam ? examDate : nil
        store.updateCourse(course)
    }

    func addTopic() {
        let title = newTopicTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, var course else { return }
        course.examTopics.append(ExamTopic(title: title))
        newTopicTitle = ""
        store.updateCourse(course)
    }

    func toggleTopic(_ id: UUID) {
        guard var course else { return }
        course.toggleExamTopic(id: id)
        store.updateCourse(course)
    }

    func deleteTopic(_ id: UUID) {
        guard var course else { return }
        course.examTopics.removeAll { $0.id == id }
        store.updateCourse(course)
    }
}
