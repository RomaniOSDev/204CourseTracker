//
//  ExamModeView.swift
//  204CourseTracker
//

import SwiftUI

struct ExamModeView: View {
    @StateObject private var viewModel: ExamModeViewModel

    init(store: CourseStore, courseId: UUID) {
        _viewModel = StateObject(wrappedValue: ExamModeViewModel(store: store, courseId: courseId))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let course = viewModel.course {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        readiness(course)
                        examDateCard
                        topicsCard(course)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .clearScrollBackground()
            }
        }
        .navigationTitle("Exam Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func readiness(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadgeView(systemImage: "rosette", tint: AppColors.secondary, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Readiness")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(course.examReadinessPercent)% prepared")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Text("\(course.examReadinessPercent)%")
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppColors.secondary)
            }
            ProgressBarView(progress: course.examReadiness, height: 12)
            if let days = course.daysUntilExam {
                MetricChip(
                    text: days >= 0 ? "Countdown: \(days) day(s)" : "Exam date passed",
                    systemImage: "calendar"
                )
            }
        }
        .softCard()
    }

    private var examDateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Deadline")
            Toggle("Certificate / Exam deadline", isOn: $viewModel.includeExam)
                .tint(AppColors.accent)
                .onChange(of: viewModel.includeExam) { _, _ in viewModel.saveExamDate() }
            if viewModel.includeExam {
                DatePicker("Exam date", selection: $viewModel.examDate, displayedComponents: .date)
                    .onChange(of: viewModel.examDate) { _, _ in viewModel.saveExamDate() }
            }
        }
        .softCard()
    }

    private func topicsCard(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Topic Checklist")
            HStack {
                TextField("New topic", text: $viewModel.newTopicTitle)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                Button("Add") { viewModel.addTopic() }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accent)
            }
            ForEach(course.examTopics) { topic in
                ChecklistTopicCell(
                    topic: topic,
                    onToggle: { viewModel.toggleTopic(topic.id) },
                    onDelete: { viewModel.deleteTopic(topic.id) }
                )
            }
        }
        .softCard()
    }
}
