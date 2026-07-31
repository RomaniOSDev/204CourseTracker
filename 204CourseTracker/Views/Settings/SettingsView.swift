//
//  SettingsView.swift
//  204CourseTracker
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    headerCard

                    VStack(spacing: 10) {
                        settingsRow(
                            title: "Rate Us",
                            subtitle: "Share quick feedback on the App Store",
                            systemImage: "star.fill",
                            tint: AppColors.accent
                        ) {
                            viewModel.rateApp()
                        }

                        settingsRow(
                            title: "Privacy Policy",
                            subtitle: "How your data is handled",
                            systemImage: "hand.raised.fill",
                            tint: AppColors.secondary
                        ) {
                            viewModel.openPrivacyPolicy()
                        }

                        settingsRow(
                            title: "Terms of Use",
                            subtitle: "Rules for using the app",
                            systemImage: "doc.text.fill",
                            tint: AppColors.secondary
                        ) {
                            viewModel.openTermsOfUse()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            IconBadgeView(systemImage: "gearshape.fill", size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text("Preferences")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Reviews, privacy, and terms.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .softCard()
    }

    private func settingsRow(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ActionMenuCell(
                title: title,
                systemImage: systemImage,
                tint: tint,
                subtitle: subtitle
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
