//
//  StudyModels.swift
//  204CourseTracker
//

import Foundation

struct StudyGoalSettings: Codable, Equatable {
    var dailyMinutesGoal: Int
    var dailyLessonsGoal: Int

    static let `default` = StudyGoalSettings(dailyMinutesGoal: 30, dailyLessonsGoal: 2)
}

struct DayActivity: Identifiable, Codable, Equatable, Hashable {
    var id: String { dayKey }
    var dayKey: String
    var minutesStudied: Int
    var lessonsCompleted: Int
    var focusSessions: Int

    init(dayKey: String, minutesStudied: Int = 0, lessonsCompleted: Int = 0, focusSessions: Int = 0) {
        self.dayKey = dayKey
        self.minutesStudied = minutesStudied
        self.lessonsCompleted = lessonsCompleted
        self.focusSessions = focusSessions
    }

    func meets(goals: StudyGoalSettings) -> Bool {
        minutesStudied >= goals.dailyMinutesGoal || lessonsCompleted >= goals.dailyLessonsGoal
    }
}

enum FocusMode: String, Codable, CaseIterable, Identifiable {
    case pomodoro
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pomodoro: return "Pomodoro"
        case .custom: return "Custom"
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .pomodoro: return 25
        case .custom: return 45
        }
    }
}

struct FocusSessionLog: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var courseId: UUID?
    var lessonId: UUID?
    var mode: FocusMode
    var plannedMinutes: Int
    var actualSeconds: Int
    var startedAt: Date
    var endedAt: Date

    var actualMinutes: Int {
        max(1, Int((Double(actualSeconds) / 60.0).rounded()))
    }
}

enum MoodLevel: String, Codable, CaseIterable, Identifiable {
    case great
    case good
    case okay
    case low

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .okay: return "Okay"
        case .low: return "Low"
        }
    }

    var systemImage: String {
        switch self {
        case .great: return "sun.max.fill"
        case .good: return "cloud.sun.fill"
        case .okay: return "cloud.fill"
        case .low: return "cloud.rain.fill"
        }
    }
}

enum EnergyLevel: String, Codable, CaseIterable, Identifiable {
    case high
    case medium
    case low

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}

struct LessonReflection: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var courseId: UUID
    var lessonId: UUID
    var mood: MoodLevel
    var energy: EnergyLevel
    var note: String?
    var createdAt: Date
}

struct ExamTopic: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

enum LearningGoalKind: String, Codable, CaseIterable, Identifiable {
    case certificate
    case hobby

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .certificate: return "Certificate"
        case .hobby: return "Hobby"
        }
    }

    var systemImage: String {
        switch self {
        case .certificate: return "rosette"
        case .hobby: return "heart.fill"
        }
    }
}

struct LearningGoal: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var kind: LearningGoalKind
    var courseIds: [UUID]
    var targetDate: Date?
    var isActive: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        kind: LearningGoalKind,
        courseIds: [UUID] = [],
        targetDate: Date? = nil,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.courseIds = courseIds
        self.targetDate = targetDate
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

struct LearningPath: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var details: String?
    var courseIds: [UUID]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        details: String? = nil,
        courseIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.courseIds = courseIds
        self.createdAt = createdAt
    }
}

struct Flashcard: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var noteId: UUID?
    var courseId: UUID
    var front: String
    var back: String
    var easiness: Double
    var intervalDays: Int
    var repetitions: Int
    var nextReviewAt: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        noteId: UUID? = nil,
        courseId: UUID,
        front: String,
        back: String,
        easiness: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0,
        nextReviewAt: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.noteId = noteId
        self.courseId = courseId
        self.front = front
        self.back = back
        self.easiness = easiness
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.nextReviewAt = nextReviewAt
        self.createdAt = createdAt
    }

    var isDue: Bool {
        nextReviewAt <= Date()
    }
}
