//
//  PersistenceService.swift
//  204CourseTracker
//

import Foundation

protocol PersistenceServing {
    func loadCourses() -> [Course]
    func saveCourses(_ courses: [Course])
    func loadNotes() -> [Note]
    func saveNotes(_ notes: [Note])
    func loadStudyGoals() -> StudyGoalSettings
    func saveStudyGoals(_ goals: StudyGoalSettings)
    func loadDayActivities() -> [DayActivity]
    func saveDayActivities(_ items: [DayActivity])
    func loadFocusSessions() -> [FocusSessionLog]
    func saveFocusSessions(_ items: [FocusSessionLog])
    func loadFlashcards() -> [Flashcard]
    func saveFlashcards(_ items: [Flashcard])
    func loadLearningPaths() -> [LearningPath]
    func saveLearningPaths(_ items: [LearningPath])
    func loadLearningGoals() -> [LearningGoal]
    func saveLearningGoals(_ items: [LearningGoal])
    func loadReflections() -> [LessonReflection]
    func saveReflections(_ items: [LessonReflection])
}

final class UserDefaultsPersistenceService: PersistenceServing {
    private enum Key {
        static let courses = "course_tracker.courses"
        static let notes = "course_tracker.notes"
        static let studyGoals = "course_tracker.studyGoals"
        static let dayActivities = "course_tracker.dayActivities"
        static let focusSessions = "course_tracker.focusSessions"
        static let flashcards = "course_tracker.flashcards"
        static let learningPaths = "course_tracker.learningPaths"
        static let learningGoals = "course_tracker.learningGoals"
        static let reflections = "course_tracker.reflections"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadCourses() -> [Course] { load([Course].self, key: Key.courses) ?? [] }
    func saveCourses(_ courses: [Course]) { save(courses, key: Key.courses) }

    func loadNotes() -> [Note] { load([Note].self, key: Key.notes) ?? [] }
    func saveNotes(_ notes: [Note]) { save(notes, key: Key.notes) }

    func loadStudyGoals() -> StudyGoalSettings {
        load(StudyGoalSettings.self, key: Key.studyGoals) ?? .default
    }

    func saveStudyGoals(_ goals: StudyGoalSettings) { save(goals, key: Key.studyGoals) }

    func loadDayActivities() -> [DayActivity] { load([DayActivity].self, key: Key.dayActivities) ?? [] }
    func saveDayActivities(_ items: [DayActivity]) { save(items, key: Key.dayActivities) }

    func loadFocusSessions() -> [FocusSessionLog] { load([FocusSessionLog].self, key: Key.focusSessions) ?? [] }
    func saveFocusSessions(_ items: [FocusSessionLog]) { save(items, key: Key.focusSessions) }

    func loadFlashcards() -> [Flashcard] { load([Flashcard].self, key: Key.flashcards) ?? [] }
    func saveFlashcards(_ items: [Flashcard]) { save(items, key: Key.flashcards) }

    func loadLearningPaths() -> [LearningPath] { load([LearningPath].self, key: Key.learningPaths) ?? [] }
    func saveLearningPaths(_ items: [LearningPath]) { save(items, key: Key.learningPaths) }

    func loadLearningGoals() -> [LearningGoal] { load([LearningGoal].self, key: Key.learningGoals) ?? [] }
    func saveLearningGoals(_ items: [LearningGoal]) { save(items, key: Key.learningGoals) }

    func loadReflections() -> [LessonReflection] { load([LessonReflection].self, key: Key.reflections) ?? [] }
    func saveReflections(_ items: [LessonReflection]) { save(items, key: Key.reflections) }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
