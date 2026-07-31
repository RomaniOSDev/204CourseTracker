//
//  SettingsViewModel.swift
//  204CourseTracker
//

import Combine
import StoreKit
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    func openPrivacyPolicy() {
        if let url = AppLinks.privacyPolicyURL {
            UIApplication.shared.open(url)
        }
    }

    func openTermsOfUse() {
        if let url = AppLinks.termsOfUseURL {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
