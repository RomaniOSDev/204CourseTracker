//
//  OnboardingPage.swift
//  204CourseTracker
//

import Foundation

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let imageName: String
    let title: String
    let message: String
    let accentLabel: String
}

enum OnboardingContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "onboard_track",
            title: "Track every course",
            message: "Organize platforms, lessons, and progress in one calm workspace built for daily learning.",
            accentLabel: "Library"
        ),
        OnboardingPage(
            id: 1,
            imageName: "onboard_focus",
            title: "Focus with intention",
            message: "Run Pomodoro sessions, hit daily goals, and keep your streak alive with lightweight study plans.",
            accentLabel: "Focus"
        ),
        OnboardingPage(
            id: 2,
            imageName: "onboard_review",
            title: "Review what sticks",
            message: "Turn notes into spaced flashcards, unlock exam readiness, and follow smart insights when you stall.",
            accentLabel: "Memory"
        )
    ]
}
