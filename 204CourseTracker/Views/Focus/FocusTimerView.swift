//
//  FocusTimerView.swift
//  204CourseTracker
//

import SwiftUI

struct FocusTimerView: View {
    @StateObject private var viewModel: FocusTimerViewModel

    init(store: CourseStore, courseId: UUID? = nil) {
        _viewModel = StateObject(wrappedValue: FocusTimerViewModel(store: store, preselectedCourseId: courseId))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 20) {
                    timerCard
                    controls
                    pickers
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Focus Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onChange(of: viewModel.mode) { _, _ in
            if !viewModel.isRunning { viewModel.resetDuration() }
        }
        .onChange(of: viewModel.customMinutes) { _, _ in
            if !viewModel.isRunning && viewModel.mode == .custom { viewModel.resetDuration() }
        }
        .alert("Session Saved", isPresented: $viewModel.didFinish) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Focus minutes were added to today’s study log.")
        }
    }

    private var timerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(AppColors.background, lineWidth: 12)
                    .frame(width: 200, height: 200)
                Circle()
                    .trim(from: 0, to: viewModel.totalSeconds == 0 ? 0 : CGFloat(viewModel.totalSeconds - viewModel.remainingSeconds) / CGFloat(viewModel.totalSeconds))
                    .stroke(
                        AppGradients.brand,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: viewModel.remainingSeconds)

                VStack(spacing: 6) {
                    Text(timeString(viewModel.remainingSeconds))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .monospacedDigit()
                    Text(viewModel.isRunning ? "Focusing" : "Ready")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Text(viewModel.selectedCourseTitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .softCard(padding: 24)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button(viewModel.isRunning ? "Pause" : "Start") { viewModel.toggle() }
                .buttonStyle(PrimaryButtonStyle())
            Button("Save") { viewModel.stopAndSave() }
                .buttonStyle(PrimaryButtonStyle(filled: false))
        }
    }

    private var pickers: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Session Setup")
            Picker("Mode", selection: $viewModel.mode) {
                ForEach(FocusMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.mode == .custom {
                Stepper("Duration: \(viewModel.customMinutes) min", value: $viewModel.customMinutes, in: 5...180, step: 5)
            }

            Picker("Course", selection: $viewModel.selectedCourseId) {
                Text("General focus").tag(UUID?.none)
                ForEach(viewModel.courses) { course in
                    Text(course.title).tag(UUID?.some(course.id))
                }
            }

            if !viewModel.lessonsForSelectedCourse.isEmpty {
                Picker("Lesson", selection: $viewModel.selectedLessonId) {
                    Text("No lesson").tag(UUID?.none)
                    ForEach(viewModel.lessonsForSelectedCourse) { lesson in
                        Text(lesson.title).tag(UUID?.some(lesson.id))
                    }
                }
            }
        }
        .softCard()
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
