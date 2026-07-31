//
//  Course.swift
//  204CourseTracker
//

import Foundation

struct Course: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var description: String?
    var platform: Platform
    var category: CourseCategory
    var lessons: [Lesson]
    var startDate: Date?
    var endDate: Date?
    var isFavorite: Bool
    var isCompleted: Bool
    var createdAt: Date
    var examDate: Date?
    var examTopics: [ExamTopic]
    var prerequisiteCourseIds: [UUID]
    var learningGoalKinds: [LearningGoalKind]

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        platform: Platform = .other,
        category: CourseCategory = .other,
        lessons: [Lesson] = [],
        startDate: Date? = nil,
        endDate: Date? = nil,
        isFavorite: Bool = false,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        examDate: Date? = nil,
        examTopics: [ExamTopic] = [],
        prerequisiteCourseIds: [UUID] = [],
        learningGoalKinds: [LearningGoalKind] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.platform = platform
        self.category = category
        self.lessons = lessons
        self.startDate = startDate
        self.endDate = endDate
        self.isFavorite = isFavorite
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.examDate = examDate
        self.examTopics = examTopics
        self.prerequisiteCourseIds = prerequisiteCourseIds
        self.learningGoalKinds = learningGoalKinds
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, platform, category, lessons
        case startDate, endDate, isFavorite, isCompleted, createdAt
        case examDate, examTopics, prerequisiteCourseIds, learningGoalKinds
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        platform = try c.decode(Platform.self, forKey: .platform)
        category = try c.decode(CourseCategory.self, forKey: .category)
        lessons = try c.decodeIfPresent([Lesson].self, forKey: .lessons) ?? []
        startDate = try c.decodeIfPresent(Date.self, forKey: .startDate)
        endDate = try c.decodeIfPresent(Date.self, forKey: .endDate)
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        examDate = try c.decodeIfPresent(Date.self, forKey: .examDate)
        examTopics = try c.decodeIfPresent([ExamTopic].self, forKey: .examTopics) ?? []
        prerequisiteCourseIds = try c.decodeIfPresent([UUID].self, forKey: .prerequisiteCourseIds) ?? []
        learningGoalKinds = try c.decodeIfPresent([LearningGoalKind].self, forKey: .learningGoalKinds) ?? []
    }

    var sortedLessons: [Lesson] {
        lessons.sorted { $0.order < $1.order }
    }

    var completedLessonsCount: Int {
        lessons.filter(\.isCompleted).count
    }

    var progress: Double {
        guard !lessons.isEmpty else { return isCompleted ? 1 : 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }

    var progressPercent: Int {
        Int((progress * 100).rounded())
    }

    var totalMinutes: Int {
        lessons.compactMap(\.duration).reduce(0, +)
    }

    var completedMinutes: Int {
        lessons.filter(\.isCompleted).compactMap(\.duration).reduce(0, +)
    }

    var examTopicProgress: Double {
        guard !examTopics.isEmpty else { return progress }
        let done = examTopics.filter(\.isCompleted).count
        return Double(done) / Double(examTopics.count)
    }

    var examReadiness: Double {
        if examTopics.isEmpty {
            return progress
        }
        return (progress * 0.6) + (examTopicProgress * 0.4)
    }

    var examReadinessPercent: Int {
        Int((examReadiness * 100).rounded())
    }

    var daysUntilExam: Int? {
        guard let examDate else { return nil }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.startOfDay(for: examDate)
        return cal.dateComponents([.day], from: start, to: end).day
    }

    mutating func syncCompletionFromLessons() {
        guard !lessons.isEmpty else { return }
        isCompleted = lessons.allSatisfy(\.isCompleted)
    }

    mutating func toggleLesson(id: UUID) {
        guard let index = lessons.firstIndex(where: { $0.id == id }) else { return }
        lessons[index].isCompleted.toggle()
        syncCompletionFromLessons()
    }

    mutating func toggleExamTopic(id: UUID) {
        guard let index = examTopics.firstIndex(where: { $0.id == id }) else { return }
        examTopics[index].isCompleted.toggle()
    }
}
