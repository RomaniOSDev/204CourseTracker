//
//  CourseStore.swift
//  204CourseTracker
//

import Foundation
import Combine

@MainActor
final class CourseStore: ObservableObject {
    @Published private(set) var courses: [Course] = []
    @Published private(set) var notes: [Note] = []
    @Published private(set) var studyGoals: StudyGoalSettings = .default
    @Published private(set) var dayActivities: [DayActivity] = []
    @Published private(set) var focusSessions: [FocusSessionLog] = []
    @Published private(set) var flashcards: [Flashcard] = []
    @Published private(set) var learningPaths: [LearningPath] = []
    @Published private(set) var learningGoals: [LearningGoal] = []
    @Published private(set) var reflections: [LessonReflection] = []

    private let persistence: PersistenceServing

    init(persistence: PersistenceServing = UserDefaultsPersistenceService()) {
        self.persistence = persistence
        courses = persistence.loadCourses()
        notes = persistence.loadNotes()
        studyGoals = persistence.loadStudyGoals()
        dayActivities = persistence.loadDayActivities()
        focusSessions = persistence.loadFocusSessions()
        flashcards = persistence.loadFlashcards()
        learningPaths = persistence.loadLearningPaths()
        learningGoals = persistence.loadLearningGoals()
        reflections = persistence.loadReflections()
    }

    // MARK: - Courses

    func course(id: UUID) -> Course? {
        courses.first { $0.id == id }
    }

    func addCourse(_ course: Course) {
        courses.insert(course, at: 0)
        persistCourses()
    }

    func updateCourse(_ course: Course) {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else { return }
        courses[index] = course
        persistCourses()
    }

    func deleteCourse(id: UUID) {
        courses.removeAll { $0.id == id }
        notes.removeAll { $0.courseId == id }
        flashcards.removeAll { $0.courseId == id }
        reflections.removeAll { $0.courseId == id }
        learningPaths = learningPaths.map { path in
            var p = path
            p.courseIds.removeAll { $0 == id }
            return p
        }
        learningGoals = learningGoals.map { goal in
            var g = goal
            g.courseIds.removeAll { $0 == id }
            return g
        }
        persistAllLinked()
    }

    func deleteCourses(at offsets: IndexSet, from source: [Course]) {
        let ids = Set(offsets.map { source[$0].id })
        ids.forEach { deleteCourse(id: $0) }
    }

    @discardableResult
    func toggleLesson(courseId: UUID, lessonId: UUID) -> Bool {
        guard let index = courses.firstIndex(where: { $0.id == courseId }) else { return false }
        let wasCompleted = courses[index].lessons.first(where: { $0.id == lessonId })?.isCompleted ?? false
        courses[index].toggleLesson(id: lessonId)
        let nowCompleted = courses[index].lessons.first(where: { $0.id == lessonId })?.isCompleted ?? false
        persistCourses()
        if !wasCompleted && nowCompleted {
            recordLessonCompletion(minutes: courses[index].lessons.first(where: { $0.id == lessonId })?.duration ?? 0)
            return true
        }
        return false
    }

    // MARK: - Notes / Flashcards

    func notes(for courseId: UUID) -> [Note] {
        notes.filter { $0.courseId == courseId }.sorted { $0.updatedAt > $1.updatedAt }
    }

    func addNote(_ note: Note) {
        notes.insert(note, at: 0)
        persistNotes()
    }

    func updateNote(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index] = note
        persistNotes()
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        flashcards.removeAll { $0.noteId == id }
        persistNotes()
        persistFlashcards()
    }

    func createFlashcards(fromNotes courseId: UUID) {
        let courseNotes = notes(for: courseId)
        for note in courseNotes {
            if flashcards.contains(where: { $0.noteId == note.id }) { continue }
            flashcards.insert(SpacedRepetitionService.makeCard(from: note), at: 0)
        }
        persistFlashcards()
    }

    func addFlashcard(_ card: Flashcard) {
        flashcards.insert(card, at: 0)
        persistFlashcards()
    }

    func reviewFlashcard(id: UUID, quality: ReviewQuality) {
        guard let index = flashcards.firstIndex(where: { $0.id == id }) else { return }
        flashcards[index] = SpacedRepetitionService.apply(quality: quality, to: flashcards[index])
        persistFlashcards()
    }

    func deleteFlashcard(id: UUID) {
        flashcards.removeAll { $0.id == id }
        persistFlashcards()
    }

    var dueFlashcards: [Flashcard] {
        flashcards.filter(\.isDue).sorted { $0.nextReviewAt < $1.nextReviewAt }
    }

    // MARK: - Study plan

    func updateStudyGoals(_ goals: StudyGoalSettings) {
        studyGoals = goals
        persistence.saveStudyGoals(goals)
    }

    var todayActivity: DayActivity {
        activity(for: DateKeys.dayKey())
    }

    func activity(for dayKey: String) -> DayActivity {
        dayActivities.first { $0.dayKey == dayKey } ?? DayActivity(dayKey: dayKey)
    }

    var currentStreak: Int {
        let map = Dictionary(uniqueKeysWithValues: dayActivities.map { ($0.dayKey, $0) })
        var streak = 0
        var cursor = Calendar.current.startOfDay(for: Date())
        let todayKey = DateKeys.dayKey(for: cursor)

        if !(map[todayKey]?.meets(goals: studyGoals) ?? false) {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }

        while true {
            let key = DateKeys.dayKey(for: cursor)
            guard let day = map[key], day.meets(goals: studyGoals) else { break }
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    func recordLessonCompletion(minutes: Int) {
        mutateToday {
            $0.lessonsCompleted += 1
            $0.minutesStudied += max(0, minutes)
        }
    }

    func recordFocusSession(_ session: FocusSessionLog) {
        focusSessions.insert(session, at: 0)
        persistence.saveFocusSessions(focusSessions)
        mutateToday {
            $0.minutesStudied += session.actualMinutes
            $0.focusSessions += 1
        }
    }

    // MARK: - Reflections

    func addReflection(_ reflection: LessonReflection) {
        reflections.insert(reflection, at: 0)
        persistence.saveReflections(reflections)
    }

    // MARK: - Paths & goals

    func addLearningPath(_ path: LearningPath) {
        learningPaths.insert(path, at: 0)
        persistence.saveLearningPaths(learningPaths)
    }

    func updateLearningPath(_ path: LearningPath) {
        guard let index = learningPaths.firstIndex(where: { $0.id == path.id }) else { return }
        learningPaths[index] = path
        persistence.saveLearningPaths(learningPaths)
    }

    func deleteLearningPath(id: UUID) {
        learningPaths.removeAll { $0.id == id }
        persistence.saveLearningPaths(learningPaths)
    }

    func addLearningGoal(_ goal: LearningGoal) {
        learningGoals.insert(goal, at: 0)
        persistence.saveLearningGoals(learningGoals)
    }

    func updateLearningGoal(_ goal: LearningGoal) {
        guard let index = learningGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        learningGoals[index] = goal
        persistence.saveLearningGoals(learningGoals)
    }

    func deleteLearningGoal(id: UUID) {
        learningGoals.removeAll { $0.id == id }
        persistence.saveLearningGoals(learningGoals)
    }

    func applyTemplate(_ template: CourseTemplate) {
        let (course, path, goal) = TemplateService.materialize(template)
        addCourse(course)
        if let path { addLearningPath(path) }
        addLearningGoal(goal)
    }

    // MARK: - Backup

    func makeBackup() -> AppBackup {
        AppBackup(
            version: AppBackup.currentVersion,
            exportedAt: Date(),
            courses: courses,
            notes: notes,
            studyGoals: studyGoals,
            dayActivities: dayActivities,
            focusSessions: focusSessions,
            flashcards: flashcards,
            learningPaths: learningPaths,
            learningGoals: learningGoals,
            reflections: reflections
        )
    }

    func replaceAll(with backup: AppBackup) {
        courses = backup.courses
        notes = backup.notes
        studyGoals = backup.studyGoals
        dayActivities = backup.dayActivities
        focusSessions = backup.focusSessions
        flashcards = backup.flashcards
        learningPaths = backup.learningPaths
        learningGoals = backup.learningGoals
        reflections = backup.reflections
        persistEverything()
    }

    // MARK: - Stats helpers

    var inProgressCourses: [Course] {
        courses.filter { !$0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
    }

    var completedCoursesCount: Int {
        courses.filter(\.isCompleted).count
    }

    var totalLessonsCount: Int {
        courses.reduce(0) { $0 + $1.lessons.count }
    }

    var completedLessonsCount: Int {
        courses.reduce(0) { $0 + $1.completedLessonsCount }
    }

    var totalMinutes: Int {
        courses.reduce(0) { $0 + $1.totalMinutes }
    }

    var overallProgress: Double {
        let total = totalLessonsCount
        guard total > 0 else {
            return courses.isEmpty ? 0 : Double(completedCoursesCount) / Double(courses.count)
        }
        return Double(completedLessonsCount) / Double(total)
    }

    func prerequisitesMet(for course: Course) -> Bool {
        course.prerequisiteCourseIds.allSatisfy { preId in
            courses.first(where: { $0.id == preId })?.isCompleted == true
        }
    }

    // MARK: - Private

    private func mutateToday(_ mutate: (inout DayActivity) -> Void) {
        let key = DateKeys.dayKey()
        if let index = dayActivities.firstIndex(where: { $0.dayKey == key }) {
            mutate(&dayActivities[index])
        } else {
            var day = DayActivity(dayKey: key)
            mutate(&day)
            dayActivities.append(day)
        }
        persistence.saveDayActivities(dayActivities)
    }

    private func persistCourses() {
        persistence.saveCourses(courses)
    }

    private func persistNotes() {
        persistence.saveNotes(notes)
    }

    private func persistFlashcards() {
        persistence.saveFlashcards(flashcards)
    }

    private func persistAllLinked() {
        persistCourses()
        persistNotes()
        persistFlashcards()
        persistence.saveLearningPaths(learningPaths)
        persistence.saveLearningGoals(learningGoals)
        persistence.saveReflections(reflections)
    }

    private func persistEverything() {
        persistence.saveCourses(courses)
        persistence.saveNotes(notes)
        persistence.saveStudyGoals(studyGoals)
        persistence.saveDayActivities(dayActivities)
        persistence.saveFocusSessions(focusSessions)
        persistence.saveFlashcards(flashcards)
        persistence.saveLearningPaths(learningPaths)
        persistence.saveLearningGoals(learningGoals)
        persistence.saveReflections(reflections)
    }
}
