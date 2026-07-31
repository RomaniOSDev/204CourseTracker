//
//  StatisticsView.swift
//  204CourseTracker
//

import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(store: store))
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    if viewModel.totalCourses == 0 {
                        EmptyStateView(
                            systemImage: "chart.bar.xaxis",
                            title: "No statistics yet",
                            message: "Add courses and complete lessons to see insights."
                        )
                        .padding(.top, 24)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            StatCardView(title: "Courses", value: "\(viewModel.totalCourses)", systemImage: "book.closed")
                            StatCardView(title: "Completed", value: "\(viewModel.completedCourses)", systemImage: "checkmark.seal", tint: AppColors.success)
                            StatCardView(title: "Lessons", value: "\(viewModel.totalLessons)", systemImage: "list.bullet", tint: AppColors.secondary)
                            StatCardView(title: "Done", value: "\(viewModel.completedLessons)", systemImage: "checkmark.circle", tint: AppColors.success)
                            StatCardView(title: "Minutes", value: "\(viewModel.totalMinutes)", systemImage: "clock")
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Course Completion")
                                    .font(.headline)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Text("\(Int((viewModel.completionRate * 100).rounded()))%")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            ProgressBarView(progress: viewModel.completionRate, height: 11)
                            Text("\(viewModel.completedCourses) of \(viewModel.totalCourses) courses completed")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .softCard()

                        VStack(spacing: 10) {
                            favoriteRow("Favorite Category", viewModel.favoriteCategoryName, "tag")
                            favoriteRow("Favorite Platform", viewModel.favoritePlatformName, "laptopcomputer")
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "By Category")
                            ForEach(viewModel.categoryStats) { stat in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Label(stat.category.displayName, systemImage: stat.category.systemImage)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(AppColors.textPrimary)
                                        Spacer()
                                        Text("\(stat.count)")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    ProgressBarView(progress: stat.share, height: 8)
                                }
                            }
                        }
                        .softCard()

                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "By Platform")
                            ForEach(viewModel.platformStats) { stat in
                                HStack {
                                    Text(stat.platform.displayName)
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    StatusBadge(text: "\(stat.count)", tint: AppColors.accent, filled: false)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .softCard()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func favoriteRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .softCard(padding: 14, radius: AppRadius.md)
    }
}
