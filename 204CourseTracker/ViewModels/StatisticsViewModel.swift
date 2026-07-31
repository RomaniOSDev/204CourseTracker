//
//  StatisticsViewModel.swift
//  204CourseTracker
//

import Foundation
import Combine

struct CategoryStat: Identifiable {
    let id: CourseCategory
    let count: Int
    let share: Double

    var category: CourseCategory { id }
}

struct PlatformStat: Identifiable {
    let id: Platform
    let count: Int

    var platform: Platform { id }
}

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published private(set) var totalCourses = 0
    @Published private(set) var completedCourses = 0
    @Published private(set) var totalLessons = 0
    @Published private(set) var completedLessons = 0
    @Published private(set) var totalMinutes = 0
    @Published private(set) var completionRate = 0.0
    @Published private(set) var favoriteCategoryName = "—"
    @Published private(set) var favoritePlatformName = "—"
    @Published private(set) var categoryStats: [CategoryStat] = []
    @Published private(set) var platformStats: [PlatformStat] = []

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        store.$courses
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
        refresh()
    }

    private func refresh() {
        let courses = store.courses
        totalCourses = courses.count
        completedCourses = store.completedCoursesCount
        totalLessons = store.totalLessonsCount
        completedLessons = store.completedLessonsCount
        totalMinutes = store.totalMinutes
        completionRate = totalCourses == 0 ? 0 : Double(completedCourses) / Double(totalCourses)

        let categoryGroups = Dictionary(grouping: courses, by: \.category)
        let maxCategory = categoryGroups.max { $0.value.count < $1.value.count }
        favoriteCategoryName = maxCategory?.key.displayName ?? "—"

        let platformGroups = Dictionary(grouping: courses, by: \.platform)
        let maxPlatform = platformGroups.max { $0.value.count < $1.value.count }
        favoritePlatformName = maxPlatform?.key.displayName ?? "—"

        let total = max(courses.count, 1)
        categoryStats = CourseCategory.allCases.compactMap { category in
            let count = categoryGroups[category]?.count ?? 0
            guard count > 0 else { return nil }
            return CategoryStat(id: category, count: count, share: Double(count) / Double(total))
        }
        .sorted { $0.count > $1.count }

        platformStats = Platform.allCases.compactMap { platform in
            let count = platformGroups[platform]?.count ?? 0
            guard count > 0 else { return nil }
            return PlatformStat(id: platform, count: count)
        }
        .sorted { $0.count > $1.count }
    }
}
