//
//  AppBackup.swift
//  204CourseTracker
//

import Foundation

struct AppBackup: Codable, Equatable {
    var version: Int
    var exportedAt: Date
    var courses: [Course]
    var notes: [Note]
    var studyGoals: StudyGoalSettings
    var dayActivities: [DayActivity]
    var focusSessions: [FocusSessionLog]
    var flashcards: [Flashcard]
    var learningPaths: [LearningPath]
    var learningGoals: [LearningGoal]
    var reflections: [LessonReflection]

    static let currentVersion = 1
}
