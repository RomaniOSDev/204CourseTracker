//
//  OnboardingViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published private(set) var didFinish = false

    let pages = OnboardingContent.pages

    private let defaults: UserDefaults
    private let completedKey = "course_tracker.onboardingCompleted"

    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "course_tracker.onboardingCompleted")
    }

    var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func next() {
        if isLastPage {
            complete()
        } else {
            currentPage += 1
        }
    }

    func skip() {
        complete()
    }

    func complete() {
        defaults.set(true, forKey: completedKey)
        didFinish = true
    }
}
