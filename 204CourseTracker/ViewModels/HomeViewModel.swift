//
//  HomeViewModel.swift
//  204CourseTracker
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var totalCourses: Int = 0
    @Published private(set) var completedCourses: Int = 0
    @Published private(set) var totalLessons: Int = 0
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var overallProgress: Double = 0
    @Published private(set) var inProgressCourses: [Course] = []
    @Published private(set) var streak: Int = 0
    @Published private(set) var todayMinutes: Int = 0
    @Published private(set) var todayLessons: Int = 0
    @Published private(set) var dueFlashcards: Int = 0
    @Published private(set) var topInsight: String?

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        Publishers.CombineLatest4(store.$courses, store.$dayActivities, store.$flashcards, store.$focusSessions)
            .combineLatest(store.$studyGoals)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.refresh()
            }
            .store(in: &cancellables)
        refresh()
    }

    private func refresh() {
        totalCourses = store.courses.count
        completedCourses = store.completedCoursesCount
        totalLessons = store.totalLessonsCount
        totalMinutes = store.totalMinutes
        overallProgress = store.overallProgress
        inProgressCourses = Array(store.inProgressCourses.prefix(8))
        streak = store.currentStreak
        todayMinutes = store.todayActivity.minutesStudied
        todayLessons = store.todayActivity.lessonsCompleted
        dueFlashcards = store.dueFlashcards.count
        topInsight = InsightsService.generate(
            courses: store.courses,
            activities: store.dayActivities,
            sessions: store.focusSessions,
            flashcards: store.flashcards,
            goals: store.studyGoals
        ).first?.title
    }
}
