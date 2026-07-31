//
//  HomeView.swift
//  204CourseTracker
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject var coordinator: AppCoordinator

    init(store: CourseStore, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(store: store))
        self.coordinator = coordinator
    }

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let statColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    HomeHeroWidget(
                        streak: viewModel.streak,
                        todayLessons: viewModel.todayLessons,
                        todayMinutes: viewModel.todayMinutes,
                        insight: viewModel.topInsight,
                        onStudyPlan: { coordinator.push(.studyPlan) },
                        onFocus: { coordinator.push(.focusTimer(nil)) }
                    )

                    if let insight = viewModel.topInsight {
                        HomeInsightBanner(text: insight) {
                            coordinator.push(.insights)
                        }
                    }

                    HomeProgressWidget(
                        progress: viewModel.overallProgress,
                        courses: viewModel.totalCourses,
                        completed: viewModel.completedCourses
                    ) {
                        coordinator.push(.statistics)
                    }

                    LazyVGrid(columns: statColumns, spacing: 10) {
                        HomeQuickStatWidget(title: "Courses", value: "\(viewModel.totalCourses)", systemImage: "book.closed")
                        HomeQuickStatWidget(title: "Done", value: "\(viewModel.completedCourses)", systemImage: "checkmark.seal", tint: AppColors.success)
                        HomeQuickStatWidget(title: "Lessons", value: "\(viewModel.totalLessons)", systemImage: "list.bullet.rectangle", tint: AppColors.secondary)
                        HomeQuickStatWidget(title: "Minutes", value: "\(viewModel.totalMinutes)", systemImage: "clock")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Today’s Widgets")

                        LazyVGrid(columns: widgetColumns, spacing: 12) {
                            HomeImageWidget(
                                title: "Streak",
                                subtitle: "Daily goals & calendar",
                                imageName: "widget_streak",
                                value: "\(viewModel.streak)d",
                                tint: AppColors.accent
                            ) {
                                coordinator.push(.studyPlan)
                            }

                            HomeImageWidget(
                                title: "Focus",
                                subtitle: "Pomodoro & session log",
                                imageName: "widget_focus",
                                value: "\(viewModel.todayMinutes)m",
                                tint: AppColors.secondary
                            ) {
                                coordinator.push(.focusTimer(nil))
                            }

                            HomeImageWidget(
                                title: "Flashcards",
                                subtitle: "Spaced repetition due",
                                imageName: "widget_cards",
                                value: "\(viewModel.dueFlashcards)",
                                tint: AppColors.accent
                            ) {
                                coordinator.push(.flashcards)
                            }

                            HomeImageWidget(
                                title: "Paths",
                                subtitle: "Roadmaps & unlocks",
                                imageName: "widget_path",
                                value: "Go",
                                tint: AppColors.secondary
                            ) {
                                coordinator.push(.learningPaths)
                            }
                        }
                    }

                    if let course = viewModel.inProgressCourses.first {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Pick Up Where You Left Off")
                            HomeContinueCourseWidget(
                                course: course,
                                onTap: { coordinator.push(.courseDetail(course.id)) },
                                onFocus: { coordinator.push(.focusTimer(course.id)) }
                            )
                        }
                    }

                    VStack(spacing: 10) {
                        Button {
                            coordinator.push(.addCourse)
                        } label: {
                            Label("New Course", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        HStack(spacing: 10) {
                            Button {
                                coordinator.push(.courseList)
                            } label: {
                                Label("All Courses", systemImage: "square.stack.3d.up")
                            }
                            .buttonStyle(PrimaryButtonStyle(filled: false))

                            Button {
                                coordinator.push(.templates)
                            } label: {
                                Label("Templates", systemImage: "square.grid.2x2")
                            }
                            .buttonStyle(PrimaryButtonStyle(filled: false))
                        }

                        HStack(spacing: 10) {
                            Button {
                                coordinator.push(.goals)
                            } label: {
                                Label("Goals", systemImage: "flag")
                            }
                            .buttonStyle(PrimaryButtonStyle(filled: false))

                            Button {
                                coordinator.push(.settings)
                            } label: {
                                Label("Settings", systemImage: "gearshape")
                            }
                            .buttonStyle(PrimaryButtonStyle(filled: false))
                        }

                        Button {
                            coordinator.push(.dataTools)
                        } label: {
                            Label("Backup", systemImage: "externaldrive")
                        }
                        .buttonStyle(PrimaryButtonStyle(filled: false))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(
                            title: "In Progress",
                            actionTitle: viewModel.inProgressCourses.isEmpty ? nil : "See All"
                        ) {
                            coordinator.push(.courseList)
                        }

                        if viewModel.inProgressCourses.isEmpty {
                            EmptyStateView(
                                systemImage: "book",
                                title: "No courses yet",
                                message: "Start with a template or add your first course.",
                                actionTitle: "Browse Templates"
                            ) {
                                coordinator.push(.templates)
                            }
                        } else {
                            ForEach(viewModel.inProgressCourses.prefix(4)) { course in
                                Button {
                                    coordinator.push(.courseDetail(course.id))
                                } label: {
                                    CourseCardView(course: course)
                                }
                                .buttonStyle(.plain)
                            }
                            .animation(.easeInOut(duration: 0.25), value: viewModel.inProgressCourses.map(\.id))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.push(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(AppColors.accent)
                }
                .accessibilityLabel("Settings")
            }
        }
    }
}
