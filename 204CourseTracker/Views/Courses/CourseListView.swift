//
//  CourseListView.swift
//  204CourseTracker
//

import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel: CourseListViewModel
    @ObservedObject var coordinator: AppCoordinator

    init(store: CourseStore, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: CourseListViewModel(store: store))
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                filtersBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                if viewModel.filteredCourses.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            systemImage: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle" : "books.vertical",
                            title: viewModel.hasActiveFilters ? "No matches" : "No courses",
                            message: viewModel.hasActiveFilters
                                ? "Try adjusting search or filters."
                                : "Add a course to start tracking progress.",
                            actionTitle: viewModel.hasActiveFilters ? "Clear Filters" : "New Course"
                        ) {
                            if viewModel.hasActiveFilters {
                                viewModel.clearFilters()
                            } else {
                                coordinator.push(.addCourse)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                    .clearScrollBackground()
                } else {
                    List {
                        ForEach(viewModel.filteredCourses) { course in
                            Button {
                                coordinator.push(.courseDetail(course.id))
                            } label: {
                                CourseCardView(course: course)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        if let index = viewModel.filteredCourses.firstIndex(where: { $0.id == course.id }) {
                                            viewModel.delete(at: IndexSet(integer: index))
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { offsets in
                            withAnimation { viewModel.delete(at: offsets) }
                        }
                    }
                    .listStyle(.plain)
                    .clearScrollBackground()
                    .animation(.easeInOut(duration: 0.25), value: viewModel.filteredCourses.map(\.id))
                }
            }
        }
        .navigationTitle("Courses")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search courses")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.push(.addCourse)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var filtersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Button("All Categories") { viewModel.selectedCategory = nil }
                    ForEach(CourseCategory.allCases) { category in
                        Button(category.displayName) { viewModel.selectedCategory = category }
                    }
                } label: {
                    FilterChipView(
                        title: viewModel.selectedCategory?.displayName ?? "Category",
                        isActive: viewModel.selectedCategory != nil,
                        showsChevron: true
                    )
                }

                Menu {
                    Button("All Platforms") { viewModel.selectedPlatform = nil }
                    ForEach(Platform.allCases) { platform in
                        Button(platform.displayName) { viewModel.selectedPlatform = platform }
                    }
                } label: {
                    FilterChipView(
                        title: viewModel.selectedPlatform?.displayName ?? "Platform",
                        isActive: viewModel.selectedPlatform != nil,
                        showsChevron: true
                    )
                }

                Button {
                    viewModel.showCompletedOnly.toggle()
                } label: {
                    FilterChipView(title: "Completed", isActive: viewModel.showCompletedOnly)
                }
                .buttonStyle(.plain)

                if viewModel.hasActiveFilters {
                    Button("Clear") { viewModel.clearFilters() }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.secondary)
                }
            }
            .padding(.vertical, 2)
        }
    }
}
