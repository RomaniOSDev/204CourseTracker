//
//  StudyPlanViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class StudyPlanViewModel: ObservableObject {
    @Published var dailyMinutesGoal: Int
    @Published var dailyLessonsGoal: Int
    @Published private(set) var streak = 0
    @Published private(set) var todayMinutes = 0
    @Published private(set) var todayLessons = 0
    @Published private(set) var calendarDays: [DayActivity] = []

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        dailyMinutesGoal = store.studyGoals.dailyMinutesGoal
        dailyLessonsGoal = store.studyGoals.dailyLessonsGoal
        Publishers.CombineLatest3(store.$studyGoals, store.$dayActivities, store.$focusSessions)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _, _ in self?.refresh() }
            .store(in: &cancellables)
        refresh()
    }

    var todayMet: Bool {
        store.todayActivity.meets(goals: store.studyGoals)
    }

    func saveGoals() {
        store.updateStudyGoals(
            StudyGoalSettings(
                dailyMinutesGoal: max(5, dailyMinutesGoal),
                dailyLessonsGoal: max(1, dailyLessonsGoal)
            )
        )
    }

    private func refresh() {
        dailyMinutesGoal = store.studyGoals.dailyMinutesGoal
        dailyLessonsGoal = store.studyGoals.dailyLessonsGoal
        streak = store.currentStreak
        todayMinutes = store.todayActivity.minutesStudied
        todayLessons = store.todayActivity.lessonsCompleted
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        calendarDays = (0..<35).reversed().compactMap { offset -> DayActivity? in
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return store.activity(for: DateKeys.dayKey(for: date))
        }
    }
}
