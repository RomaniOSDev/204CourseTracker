//
//  Lesson.swift
//  204CourseTracker
//

import Foundation

struct Lesson: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var duration: Int?
    var isCompleted: Bool
    var order: Int

    init(
        id: UUID = UUID(),
        title: String,
        duration: Int? = nil,
        isCompleted: Bool = false,
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.duration = duration
        self.isCompleted = isCompleted
        self.order = order
    }
}
