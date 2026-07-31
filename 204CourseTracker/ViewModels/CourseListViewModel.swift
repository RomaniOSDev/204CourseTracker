//
//  CourseListViewModel.swift
//  204CourseTracker
//

import Foundation
import Combine

@MainActor
final class CourseListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: CourseCategory?
    @Published var selectedPlatform: Platform?
    @Published var showCompletedOnly = false
    @Published private(set) var filteredCourses: [Course] = []

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store

        Publishers.CombineLatest4(
            store.$courses,
            $searchText,
            $selectedCategory,
            $selectedPlatform
        )
        .combineLatest($showCompletedOnly)
        .receive(on: RunLoop.main)
        .sink { [weak self] combined, showCompleted in
            let (courses, search, category, platform) = combined
            self?.applyFilters(
                courses: courses,
                search: search,
                category: category,
                platform: platform,
                showCompletedOnly: showCompleted
            )
        }
        .store(in: &cancellables)
    }

    var hasActiveFilters: Bool {
        selectedCategory != nil || selectedPlatform != nil || showCompletedOnly || !searchText.isEmpty
    }

    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedPlatform = nil
        showCompletedOnly = false
    }

    func delete(at offsets: IndexSet) {
        store.deleteCourses(at: offsets, from: filteredCourses)
    }

    private func applyFilters(
        courses: [Course],
        search: String,
        category: CourseCategory?,
        platform: Platform?,
        showCompletedOnly: Bool
    ) {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        filteredCourses = courses.filter { course in
            if showCompletedOnly && !course.isCompleted { return false }
            if let category, course.category != category { return false }
            if let platform, course.platform != platform { return false }
            if !query.isEmpty {
                let haystack = [
                    course.title,
                    course.description ?? "",
                    course.category.displayName,
                    course.platform.displayName
                ].joined(separator: " ").lowercased()
                if !haystack.contains(query) { return false }
            }
            return true
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
}
