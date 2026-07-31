//
//  LearningPathViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class LearningPathViewModel: ObservableObject {
    @Published private(set) var paths: [LearningPath] = []
    @Published var newTitle = ""
    @Published var newDetails = ""
    @Published var selectedCourseIds: Set<UUID> = []
    @Published var showComposer = false

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        store.$learningPaths
            .receive(on: RunLoop.main)
            .sink { [weak self] paths in self?.paths = paths }
            .store(in: &cancellables)
    }

    var courses: [Course] { store.courses }

    func courseTitle(_ id: UUID) -> String {
        store.course(id: id)?.title ?? "Missing course"
    }

    func progress(for path: LearningPath) -> Double {
        let list = path.courseIds.compactMap { store.course(id: $0) }
        guard !list.isEmpty else { return 0 }
        return list.map(\.progress).reduce(0, +) / Double(list.count)
    }

    func isUnlocked(_ courseId: UUID, in path: LearningPath) -> Bool {
        guard let course = store.course(id: courseId) else { return false }
        guard let index = path.courseIds.firstIndex(of: courseId) else { return true }
        let previous = path.courseIds.prefix(index)
        return previous.allSatisfy { store.course(id: $0)?.isCompleted == true } && store.prerequisitesMet(for: course)
    }

    func createPath() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let ordered = courses.map(\.id).filter { selectedCourseIds.contains($0) }
        // Keep user selection order by selected set iteration fallback:
        let ids = courses.filter { selectedCourseIds.contains($0.id) }.map(\.id)
        let details = newDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        store.addLearningPath(
            LearningPath(
                title: title,
                details: details.isEmpty ? nil : details,
                courseIds: ids.isEmpty ? ordered : ids
            )
        )
        // Wire sequential prerequisites
        let finalIds = ids
        for (idx, courseId) in finalIds.enumerated() where idx > 0 {
            if var course = store.course(id: courseId) {
                let pre = finalIds[idx - 1]
                if !course.prerequisiteCourseIds.contains(pre) {
                    course.prerequisiteCourseIds.append(pre)
                    store.updateCourse(course)
                }
            }
        }
        newTitle = ""
        newDetails = ""
        selectedCourseIds = []
        showComposer = false
    }

    func delete(_ path: LearningPath) {
        store.deleteLearningPath(id: path.id)
    }
}
