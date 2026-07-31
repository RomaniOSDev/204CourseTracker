//
//  CourseFormView.swift
//  204CourseTracker
//

import SwiftUI

struct CourseFormView: View {
    @StateObject private var viewModel: CourseFormViewModel
    @ObservedObject var coordinator: AppCoordinator
    @FocusState private var focusedLessonID: UUID?

    init(store: CourseStore, mode: CourseFormMode, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: CourseFormViewModel(store: store, mode: mode))
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 18) {
                    basicsSection
                    datesSection
                    favoriteSection
                    lessonsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    viewModel.save()
                    if viewModel.didSave {
                        coordinator.pop()
                    }
                }
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.canSave ? AppColors.accent : AppColors.textSecondary)
                .disabled(!viewModel.canSave)
            }
        }
        .alert(
            "Missing Information",
            isPresented: Binding(
                get: { viewModel.validationMessage != nil },
                set: { if !$0 { viewModel.validationMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.validationMessage ?? "")
        }
    }

    private var basicsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Details")

            labeledField("Title") {
                TextField("Course title", text: $viewModel.title)
                    .textInputAutocapitalization(.sentences)
            }

            labeledField("Description") {
                TextField("Optional description", text: $viewModel.descriptionText, axis: .vertical)
                    .lineLimit(3...6)
            }

            labeledField("Platform") {
                Picker("Platform", selection: $viewModel.platform) {
                    ForEach(Platform.allCases) { platform in
                        Text(platform.displayName).tag(platform)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.accent)
            }

            labeledField("Category") {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(CourseCategory.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.accent)
            }
        }
        .softCard()
    }

    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Schedule")

            Toggle("Start Date", isOn: $viewModel.includeStartDate)
                .tint(AppColors.accent)

            if viewModel.includeStartDate {
                DatePicker("Starts", selection: $viewModel.startDate, displayedComponents: .date)
                    .tint(AppColors.accent)
            }

            Toggle("End Date", isOn: $viewModel.includeEndDate)
                .tint(AppColors.accent)

            if viewModel.includeEndDate {
                DatePicker("Ends", selection: $viewModel.endDate, displayedComponents: .date)
                    .tint(AppColors.accent)
            }
        }
        .softCard()
    }

    private var favoriteSection: some View {
        Toggle(isOn: $viewModel.isFavorite) {
            Label("Favorite", systemImage: "star.fill")
                .foregroundStyle(AppColors.textPrimary)
        }
        .tint(AppColors.accent)
        .softCard()
    }

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionTitle("Lessons")
                Spacer()
                Button {
                    withAnimation { viewModel.addLesson() }
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.accent)
                }
            }

            if viewModel.draftLessons.isEmpty {
                Text("Add lessons with titles and optional duration in minutes.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                ForEach($viewModel.draftLessons) { $lesson in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            TextField("Lesson title", text: $lesson.title)
                                .focused($focusedLessonID, equals: lesson.id)

                            Button(role: .destructive) {
                                withAnimation { viewModel.removeLesson(lesson) }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(AppColors.danger)
                            }
                        }

                        TextField("Duration (minutes)", text: $lesson.durationText)
                            .keyboardType(.numberPad)
                    }
                    .padding(12)
                    .background(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.draftLessons.map(\.id))
            }
        }
        .softCard()
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
            content()
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
