//
//  SpacedRepetitionService.swift
//  204CourseTracker
//

import Foundation

enum ReviewQuality: Int {
    case again = 1
    case hard = 2
    case good = 3
    case easy = 4
}

enum SpacedRepetitionService {
    static func apply(quality: ReviewQuality, to card: Flashcard, now: Date = Date()) -> Flashcard {
        var updated = card
        let q = quality.rawValue

        if q >= 3 {
            if updated.repetitions == 0 {
                updated.intervalDays = 1
            } else if updated.repetitions == 1 {
                updated.intervalDays = 6
            } else {
                updated.intervalDays = max(1, Int((Double(updated.intervalDays) * updated.easiness).rounded()))
            }
            updated.repetitions += 1
        } else {
            updated.repetitions = 0
            updated.intervalDays = 1
        }

        let easiness = updated.easiness + (0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02))
        updated.easiness = min(max(easiness, 1.3), 3.0)
        updated.nextReviewAt = Calendar.current.date(byAdding: .day, value: updated.intervalDays, to: now) ?? now
        return updated
    }

    static func makeCard(from note: Note) -> Flashcard {
        Flashcard(
            noteId: note.id,
            courseId: note.courseId,
            front: note.title,
            back: note.content
        )
    }
}
