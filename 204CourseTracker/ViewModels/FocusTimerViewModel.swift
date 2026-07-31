//
//  FocusTimerViewModel.swift
//  204CourseTracker
//

import Combine
import Foundation

@MainActor
final class FocusTimerViewModel: ObservableObject {
    @Published var mode: FocusMode = .pomodoro
    @Published var customMinutes: Int = 45
    @Published var selectedCourseId: UUID?
    @Published var selectedLessonId: UUID?
    @Published var remainingSeconds: Int = 25 * 60
    @Published var totalSeconds: Int = 25 * 60
    @Published var isRunning = false
    @Published var didFinish = false

    private let store: CourseStore
    private var timer: AnyCancellable?
    private var startedAt: Date?

    var courses: [Course] { store.courses }

    var lessonsForSelectedCourse: [Lesson] {
        guard let id = selectedCourseId else { return [] }
        return store.course(id: id)?.sortedLessons ?? []
    }

    var selectedCourseTitle: String {
        guard let id = selectedCourseId else { return "General focus" }
        return store.course(id: id)?.title ?? "General focus"
    }

    init(store: CourseStore, preselectedCourseId: UUID? = nil) {
        self.store = store
        self.selectedCourseId = preselectedCourseId ?? store.inProgressCourses.first?.id
        resetDuration()
    }

    func resetDuration() {
        let minutes = mode == .pomodoro ? FocusMode.pomodoro.defaultMinutes : max(5, customMinutes)
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
        isRunning = false
        timer?.cancel()
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        if remainingSeconds <= 0 { resetDuration() }
        isRunning = true
        if startedAt == nil { startedAt = Date() }
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func stopAndSave() {
        let elapsed = totalSeconds - remainingSeconds
        guard elapsed >= 15 else {
            cancel()
            return
        }
        let session = FocusSessionLog(
            id: UUID(),
            courseId: selectedCourseId,
            lessonId: selectedLessonId,
            mode: mode,
            plannedMinutes: totalSeconds / 60,
            actualSeconds: elapsed,
            startedAt: startedAt ?? Date().addingTimeInterval(TimeInterval(-elapsed)),
            endedAt: Date()
        )
        store.recordFocusSession(session)
        cancel()
        didFinish = true
    }

    func cancel() {
        timer?.cancel()
        isRunning = false
        startedAt = nil
        resetDuration()
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            stopAndSave()
            return
        }
        remainingSeconds -= 1
    }
}
