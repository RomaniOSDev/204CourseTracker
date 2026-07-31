//
//  LearningPathView.swift
//  204CourseTracker
//

import SwiftUI

struct LearningPathView: View {
    @StateObject private var viewModel: LearningPathViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: LearningPathViewModel(store: store))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    Button {
                        viewModel.showComposer = true
                    } label: {
                        Label("New Roadmap", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    if viewModel.paths.isEmpty {
                        EmptyStateView(
                            systemImage: "map",
                            title: "No learning paths",
                            message: "Build a roadmap with ordered courses and prerequisites."
                        )
                    } else {
                        ForEach(viewModel.paths) { path in
                            PathCardCell(
                                path: path,
                                progress: viewModel.progress(for: path),
                                steps: path.courseIds.enumerated().map { index, id in
                                    (index: index + 1, title: viewModel.courseTitle(id), unlocked: viewModel.isUnlocked(id, in: path))
                                },
                                onDelete: { viewModel.delete(path) }
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
        .navigationTitle("Learning Paths")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.showComposer) {
            NavigationStack {
                Form {
                    TextField("Path title", text: $viewModel.newTitle)
                    TextField("Details", text: $viewModel.newDetails, axis: .vertical)
                    Section("Courses in order") {
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
                .navigationTitle("New Path")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { viewModel.showComposer = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") { viewModel.createPath() }
                    }
                }
            }
        }
    }
}
