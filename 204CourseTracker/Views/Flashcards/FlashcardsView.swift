//
//  FlashcardsView.swift
//  204CourseTracker
//

import SwiftUI

struct FlashcardsView: View {
    @StateObject private var viewModel: FlashcardsViewModel
    private let store: CourseStore

    init(store: CourseStore) {
        self.store = store
        _viewModel = StateObject(wrappedValue: FlashcardsViewModel(store: store))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    tools
                    if let card = viewModel.currentCard {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { viewModel.flip() }
                        } label: {
                            FlashcardFaceCell(
                                label: viewModel.showBack ? "Answer" : "Prompt",
                                text: viewModel.showBack ? card.back : card.front,
                                showHint: true
                            )
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 8) {
                            rate("Again", .again, AppColors.danger)
                            rate("Hard", .hard, AppColors.secondary)
                            rate("Good", .good, AppColors.accent)
                            rate("Easy", .easy, AppColors.success)
                        }
                    } else {
                        EmptyStateView(
                            systemImage: "rectangle.on.rectangle.angled",
                            title: "No cards due",
                            message: "Generate cards from course notes or check back later."
                        )
                    }

                    Text("\(viewModel.dueCards.count) due · \(viewModel.allCards.count) total")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var tools: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Deck")
            Picker("Course filter", selection: $viewModel.selectedCourseFilter) {
                Text("All courses").tag(UUID?.none)
                ForEach(viewModel.courses) { course in
                    Text(course.title).tag(UUID?.some(course.id))
                }
            }
            .onChange(of: viewModel.selectedCourseFilter) { _, _ in viewModel.refresh() }

            if let courseId = viewModel.selectedCourseFilter {
                Button("Generate from Notes") { viewModel.generateFromNotes(courseId: courseId) }
                    .buttonStyle(PrimaryButtonStyle(filled: false))
            } else if let first = store.courses.first {
                Button("Generate from “\(first.title)” notes") {
                    viewModel.generateFromNotes(courseId: first.id)
                }
                .buttonStyle(PrimaryButtonStyle(filled: false))
            }
        }
        .softCard()
    }

    private func rate(_ title: String, _ quality: ReviewQuality, _ color: Color) -> some View {
        Button(title) {
            withAnimation { viewModel.rate(quality) }
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }
}
