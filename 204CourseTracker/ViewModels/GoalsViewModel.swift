//
//  GoalsViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class GoalsViewModel: ObservableObject {
    @Published private(set) var goals: [LearningGoal] = []
    @Published var title = ""
    @Published var kind: LearningGoalKind = .certificate
    @Published var targetDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @Published var includeDate = true
    @Published var selectedCourseIds: Set<UUID> = []
    @Published var showComposer = false

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        store.$learningGoals
            .receive(on: RunLoop.main)
            .sink { [weak self] goals in self?.goals = goals }
            .store(in: &cancellables)
    }

    var courses: [Course] { store.courses }

    func progress(for goal: LearningGoal) -> Double {
        let list = goal.courseIds.compactMap { store.course(id: $0) }
        guard !list.isEmpty else { return 0 }
        return list.map(\.progress).reduce(0, +) / Double(list.count)
    }

    func create() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let ids = courses.filter { selectedCourseIds.contains($0.id) }.map(\.id)
        store.addLearningGoal(
            LearningGoal(
                title: trimmed,
                kind: kind,
                courseIds: ids,
                targetDate: includeDate ? targetDate : nil,
                isActive: true
            )
        )
        for id in ids {
            if var course = store.course(id: id) {
                if !course.learningGoalKinds.contains(kind) {
                    course.learningGoalKinds.append(kind)
                    store.updateCourse(course)
                }
            }
        }
        title = ""
        selectedCourseIds = []
        showComposer = false
    }

    func delete(_ goal: LearningGoal) {
        store.deleteLearningGoal(id: goal.id)
    }

    func toggleActive(_ goal: LearningGoal) {
        var updated = goal
        updated.isActive.toggle()
        store.updateLearningGoal(updated)
    }
}
