//
//  FlashcardsViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class FlashcardsViewModel: ObservableObject {
    @Published private(set) var dueCards: [Flashcard] = []
    @Published private(set) var allCards: [Flashcard] = []
    @Published var currentIndex = 0
    @Published var showBack = false
    @Published var selectedCourseFilter: UUID?

    private let store: CourseStore
    private var cancellables = Set<AnyCancellable>()

    init(store: CourseStore) {
        self.store = store
        store.$flashcards
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
        refresh()
    }

    var courses: [Course] { store.courses }

    var currentCard: Flashcard? {
        guard dueCards.indices.contains(currentIndex) else { return nil }
        return dueCards[currentIndex]
    }

    func refresh() {
        allCards = store.flashcards.sorted { $0.nextReviewAt < $1.nextReviewAt }
        var due = store.dueFlashcards
        if let filter = selectedCourseFilter {
            due = due.filter { $0.courseId == filter }
        }
        dueCards = due
        if currentIndex >= dueCards.count {
            currentIndex = max(0, dueCards.count - 1)
        }
        showBack = false
    }

    func generateFromNotes(courseId: UUID) {
        store.createFlashcards(fromNotes: courseId)
        refresh()
    }

    func rate(_ quality: ReviewQuality) {
        guard let card = currentCard else { return }
        store.reviewFlashcard(id: card.id, quality: quality)
        showBack = false
        if currentIndex >= dueCards.count - 1 {
            currentIndex = 0
        }
        refresh()
    }

    func flip() {
        showBack.toggle()
    }
}
