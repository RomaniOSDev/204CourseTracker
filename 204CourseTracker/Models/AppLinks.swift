//
//  AppLinks.swift
//  204CourseTracker
//

import Foundation

enum AppLinks {
    static let privacyPolicy = "https://www.termsfeed.com/live/e9a8f98a-0643-47cd-84b0-0a55d7b4d6b2"
    static let termsOfUse = "https://www.termsfeed.com/live/beb7a4af-e8f6-494b-a692-9b9904801b04"

    static var privacyPolicyURL: URL? {
        URL(string: privacyPolicy)
    }

    static var termsOfUseURL: URL? {
        URL(string: termsOfUse)
    }
}
