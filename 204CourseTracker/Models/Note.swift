//
//  Note.swift
//  204CourseTracker
//

import Foundation

struct Note: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var courseId: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        courseId: UUID,
        title: String,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.courseId = courseId
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
