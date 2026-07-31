//
//  CourseDetailView.swift
//  204CourseTracker
//

import SwiftUI

struct CourseDetailView: View {
    @StateObject private var viewModel: CourseDetailViewModel
    @ObservedObject var coordinator: AppCoordinator

    init(store: CourseStore, courseId: UUID, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(store: store, courseId: courseId))
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            if let course = viewModel.course {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        header(course)
                        progressCard(course)
                        if course.examDate != nil || !course.examTopics.isEmpty {
                            examPreview(course)
                        }
                        lessonsSection(course)
                        actionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .clearScrollBackground()
            } else {
                EmptyStateView(
                    systemImage: "exclamationmark.triangle",
                    title: "Course not found",
                    message: "This course may have been deleted."
                )
                .padding(20)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert("Delete Course?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCourse()
                coordinator.pop()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will also remove related notes.")
        }
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted { coordinator.pop() }
        }
        .sheet(isPresented: $viewModel.showReflection) {
            MoodReflectionSheet(
                mood: $viewModel.reflectionMood,
                energy: $viewModel.reflectionEnergy,
                note: $viewModel.reflectionNote,
                onSave: { viewModel.saveReflection() },
                onSkip: { viewModel.skipReflection() }
            )
        }
    }

    private func header(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadgeView(systemImage: course.category.systemImage, size: 52)
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    HStack(spacing: 6) {
                        MetricChip(text: course.category.displayName, systemImage: "tag")
                        MetricChip(text: course.platform.displayName, systemImage: "laptopcomputer")
                    }
                }
                Spacer(minLength: 0)
                if course.isCompleted {
                    StatusBadge(text: "Completed", tint: AppColors.success)
                }
            }

            if course.isFavorite {
                Label("Favorite course", systemImage: "star.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.accent)
            }

            if let description = course.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .softCard()
    }

    private func progressCard(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(course.progressPercent)%")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.secondary)
            }
            ProgressBarView(progress: course.progress, height: 11)
            Text("\(course.completedLessonsCount) of \(course.lessons.count) lessons completed")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .softCard()
    }

    private func examPreview(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Exam Readiness", systemImage: "rosette")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(course.examReadinessPercent)%")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.secondary)
            }
            ProgressBarView(progress: course.examReadiness)
            if let days = course.daysUntilExam {
                Text(days >= 0 ? "\(days) day(s) until exam" : "Exam date passed")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .softCard()
    }

    private func lessonsSection(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Lessons")

            if course.lessons.isEmpty {
                Text("No lessons added yet.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .softCard()
            } else {
                ForEach(course.sortedLessons) { lesson in
                    LessonRowCell(lesson: lesson) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleLesson(lesson.id)
                        }
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            SectionHeaderView(title: "Actions")
            Button { coordinator.push(.focusTimer(viewModel.courseId)) } label: {
                ActionMenuCell(title: "Focus Timer", systemImage: "timer", subtitle: "Log a study session")
            }
            .buttonStyle(.plain)

            Button { coordinator.push(.examMode(viewModel.courseId)) } label: {
                ActionMenuCell(title: "Exam Mode", systemImage: "rosette", tint: AppColors.secondary, subtitle: "Deadline & topic checklist")
            }
            .buttonStyle(.plain)

            Button { coordinator.push(.notes(viewModel.courseId)) } label: {
                ActionMenuCell(title: "Notes", systemImage: "note.text", subtitle: "Ideas and flashcard source")
            }
            .buttonStyle(.plain)

            Button { coordinator.push(.editCourse(viewModel.courseId)) } label: {
                ActionMenuCell(title: "Edit", systemImage: "pencil", tint: AppColors.secondary, subtitle: "Update details and lessons")
            }
            .buttonStyle(.plain)

            Button { viewModel.showDeleteConfirmation = true } label: {
                ActionMenuCell(title: "Delete", systemImage: "trash", tint: AppColors.danger, subtitle: "Remove course and related notes")
            }
            .buttonStyle(.plain)
        }
    }
}
