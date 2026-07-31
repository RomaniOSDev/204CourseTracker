//
//  InsightsViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published private(set) var insights: [InsightItem] = []

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        Publishers.CombineLatest4(store.$courses, store.$dayActivities, store.$focusSessions, store.$flashcards)
            .combineLatest(store.$studyGoals)
            .receive(on: RunLoop.main)
            .sink { [weak self] combined, goals in
                let (courses, activities, sessions, cards) = combined
                self?.insights = InsightsService.generate(
                    courses: courses,
                    activities: activities,
                    sessions: sessions,
                    flashcards: cards,
                    goals: goals
                )
            }
            .store(in: &cancellables)
    }
}
