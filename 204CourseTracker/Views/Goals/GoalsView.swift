//
//  GoalsView.swift
//  204CourseTracker
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel: GoalsViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(store: store))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    Button { viewModel.showComposer = true } label: {
                        Label("Add Goal", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Text("Run Certificate and Hobby goals in parallel.")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if viewModel.goals.isEmpty {
                        EmptyStateView(
                            systemImage: "flag",
                            title: "No goals yet",
                            message: "Create certificate and hobby tracks linked to courses."
                        )
                    } else {
                        ForEach(viewModel.goals) { goal in
                            GoalCardCell(
                                goal: goal,
                                progress: viewModel.progress(for: goal),
                                onToggle: { viewModel.toggleActive(goal) },
                                onDelete: { viewModel.delete(goal) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.showComposer) {
            NavigationStack {
                Form {
                    TextField("Goal title", text: $viewModel.title)
                    Picker("Type", selection: $viewModel.kind) {
                        ForEach(LearningGoalKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    Toggle("Target date", isOn: $viewModel.includeDate)
                    if viewModel.includeDate {
                        DatePicker("Date", selection: $viewModel.targetDate, displayedComponents: .date)
                    }
                    Section("Courses") {
                        ForEach(viewModel.courses) { course in
                            Toggle(course.title, isOn: Binding(
                                get: { viewModel.selectedCourseIds.contains(course.id) },
                                set: { enabled in
                                    if enabled { viewModel.selectedCourseIds.insert(course.id) }
                                    else { viewModel.selectedCourseIds.remove(course.id) }
                                }
                            ))
                        }
                    }
                }
                .navigationTitle("New Goal")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { viewModel.showComposer = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") { viewModel.create() }
                    }
                }
            }
        }
    }
}
