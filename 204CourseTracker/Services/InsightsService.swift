//
//  InsightsService.swift
//  204CourseTracker
//

import Foundation

struct InsightItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
    let priority: Int
}

enum InsightsService {
    static func generate(
        courses: [Course],
        activities: [DayActivity],
        sessions: [FocusSessionLog],
        flashcards: [Flashcard],
        goals: StudyGoalSettings
    ) -> [InsightItem] {
        var items: [InsightItem] = []
        let cal = Calendar.current
        let todayKey = DateKeys.dayKey()

        let sortedKeys = activities.map(\.dayKey).sorted(by: >)
        var inactiveDays = 0
        if let last = sortedKeys.first, let lastDate = DateKeys.date(fromDayKey: last) {
            inactiveDays = max(0, cal.dateComponents([.day], from: cal.startOfDay(for: lastDate), to: cal.startOfDay(for: Date())).day ?? 0)
            if last == todayKey { inactiveDays = 0 }
        } else if !courses.isEmpty {
            inactiveDays = 7
        }

        if inactiveDays >= 3 {
            items.append(
                InsightItem(
                    title: "You haven’t studied in \(inactiveDays) days",
                    detail: "A short \(goals.dailyMinutesGoal)-minute session will restart your streak.",
                    systemImage: "exclamationmark.bubble",
                    priority: 100
                )
            )
        }

        let categoryMinutes = Dictionary(grouping: sessions.compactMap { session -> (CourseCategory, Int)? in
            guard let courseId = session.courseId,
                  let course = courses.first(where: { $0.id == courseId }) else { return nil }
            return (course.category, session.actualMinutes)
        }, by: \.0).mapValues { pairs in pairs.reduce(0) { $0 + $1.1 } }

        let totalFocus = categoryMinutes.values.reduce(0, +)
        if totalFocus > 0, let top = categoryMinutes.max(by: { $0.value < $1.value }) {
            let share = Int((Double(top.value) / Double(totalFocus) * 100).rounded())
            items.append(
                InsightItem(
                    title: "\(top.key.displayName) takes \(share)% of focus time",
                    detail: "Balance your week with another category if you want broader progress.",
                    systemImage: "chart.pie",
                    priority: 80
                )
            )
        }

        let due = flashcards.filter(\.isDue).count
        if due > 0 {
            items.append(
                InsightItem(
                    title: "\(due) flashcards are due",
                    detail: "Spaced reviews keep notes sticky with less effort.",
                    systemImage: "rectangle.on.rectangle.angled",
                    priority: 90
                )
            )
        }

        let upcomingExams = courses.compactMap { course -> (Course, Int)? in
            guard let days = course.daysUntilExam, days >= 0, days <= 14 else { return nil }
            return (course, days)
        }
        .sorted { $0.1 < $1.1 }

        if let exam = upcomingExams.first {
            items.append(
                InsightItem(
                    title: "\(exam.0.title) exam in \(exam.1) days",
                    detail: "Readiness \(exam.0.examReadinessPercent)%. Review checklist topics next.",
                    systemImage: "rosette",
                    priority: 95
                )
            )
        }

        let today = activities.first { $0.dayKey == todayKey }
        if let today, !today.meets(goals: goals) {
            let missingMinutes = max(0, goals.dailyMinutesGoal - today.minutesStudied)
            let missingLessons = max(0, goals.dailyLessonsGoal - today.lessonsCompleted)
            items.append(
                InsightItem(
                    title: "Daily goal still open",
                    detail: "Need \(missingMinutes) min or \(missingLessons) more lesson(s) today.",
                    systemImage: "target",
                    priority: 70
                )
            )
        } else if today == nil && !courses.isEmpty {
            items.append(
                InsightItem(
                    title: "Start today’s plan",
                    detail: "Hit \(goals.dailyLessonsGoal) lessons or \(goals.dailyMinutesGoal) minutes.",
                    systemImage: "sunrise",
                    priority: 75
                )
            )
        }

        let incomplete = courses.filter { !$0.isCompleted }
        if let stalled = incomplete.min(by: { $0.progress < $1.progress }), stalled.progress < 0.25, incomplete.count > 1 {
            items.append(
                InsightItem(
                    title: "Boost “\(stalled.title)”",
                    detail: "Only \(stalled.progressPercent)% done — finish one lesson to regain momentum.",
                    systemImage: "hare",
                    priority: 60
                )
            )
        }

        if items.isEmpty {
            items.append(
                InsightItem(
                    title: "You’re on track",
                    detail: "Keep logging focus sessions and reviews to unlock richer insights.",
                    systemImage: "checkmark.seal",
                    priority: 10
                )
            )
        }

        return items.sorted { $0.priority > $1.priority }
    }
}
