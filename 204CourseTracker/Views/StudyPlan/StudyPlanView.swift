//
//  StudyPlanView.swift
//  204CourseTracker
//

import SwiftUI

struct StudyPlanView: View {
    @StateObject private var viewModel: StudyPlanViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: StudyPlanViewModel(store: store))
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    StreakHeroCell(
                        streak: viewModel.streak,
                        todayLessons: viewModel.todayLessons,
                        todayMinutes: viewModel.todayMinutes,
                        insight: viewModel.todayMet ? "Daily goal completed — great work." : "Keep going to hit today’s goal.",
                        dueFlashcards: 0
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeaderView(title: "Daily Goals")
                        Stepper("Minutes: \(viewModel.dailyMinutesGoal)", value: $viewModel.dailyMinutesGoal, in: 5...240, step: 5)
                        Stepper("Lessons: \(viewModel.dailyLessonsGoal)", value: $viewModel.dailyLessonsGoal, in: 1...20)
                        Button("Save Goals") { viewModel.saveGoals() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    .softCard()

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Completion Calendar")
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(viewModel.calendarDays) { day in
                                CalendarDayCell(
                                    day: day,
                                    goals: StudyGoalSettings(
                                        dailyMinutesGoal: viewModel.dailyMinutesGoal,
                                        dailyLessonsGoal: viewModel.dailyLessonsGoal
                                    )
                                )
                            }
                        }
                        HStack(spacing: 12) {
                            legend(AppColors.background, "Empty")
                            legend(AppColors.accent.opacity(0.35), "Partial")
                            legend(AppColors.accent, "Goal met")
                        }
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                    }
                    .softCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Study Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func legend(_ color: Color, _ title: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title)
        }
    }
}
