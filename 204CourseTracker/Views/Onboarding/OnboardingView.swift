//
//  OnboardingView.swift
//  204CourseTracker
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageCard(page: page)
                            .tag(page.id)
                            .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: viewModel.didFinish) { _, finished in
            if finished { onFinished() }
        }
    }

    private var topBar: some View {
        HStack {
            StatusBadge(
                text: viewModel.pages[safe: viewModel.currentPage]?.accentLabel ?? "Welcome",
                tint: AppColors.accent,
                filled: false
            )
            Spacer()
            if !viewModel.isLastPage {
                Button("Skip") {
                    viewModel.skip()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(viewModel.pages) { page in
                    Capsule()
                        .fill(page.id == viewModel.currentPage ? AppColors.accent : AppColors.textSecondary.opacity(0.25))
                        .overlay {
                            if page.id == viewModel.currentPage {
                                Capsule().fill(AppGradients.brandHorizontal)
                            }
                        }
                        .frame(
                            width: page.id == viewModel.currentPage ? 22 : 8,
                            height: 8
                        )
                        .animation(.easeOut(duration: 0.2), value: viewModel.currentPage)
                }
            }

            Button {
                viewModel.next()
            } label: {
                Label(
                    viewModel.isLastPage ? "Get Started" : "Continue",
                    systemImage: viewModel.isLastPage ? "checkmark.circle.fill" : "arrow.right.circle.fill"
                )
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

private struct OnboardingPageCard: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 18) {
            ZStack(alignment: .bottomLeading) {
                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipped()

                AppGradients.heroScrim
                    .frame(height: 140)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                VStack(alignment: .leading, spacing: 6) {
                    StatusBadge(text: page.accentLabel, tint: AppColors.accent)
                    Text(page.title)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(18)
            }
            .frame(height: 340)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .compositingGroup()
            .shadow(
                color: AppDepth.floating.shadowColor,
                radius: AppDepth.floating.radius,
                x: 0,
                y: AppDepth.floating.y
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(page.message)
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    featureChip(systemImage: "checkmark.seal.fill", text: "Offline")
                    featureChip(systemImage: "flame.fill", text: "Streaks")
                    featureChip(systemImage: "timer", text: "Focus")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard(padding: 16, depth: .raised)

            Spacer(minLength: 0)
        }
        .padding(.top, 12)
    }

    private func featureChip(systemImage: String, text: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppColors.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppColors.accent.opacity(0.10))
            .clipShape(Capsule())
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    OnboardingView(onFinished: {})
}
