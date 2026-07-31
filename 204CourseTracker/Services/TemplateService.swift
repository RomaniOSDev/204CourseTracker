//
//  TemplateService.swift
//  204CourseTracker
//

import Foundation

struct CourseTemplate: Identifiable {
    let id: String
    let title: String
    let details: String
    let category: CourseCategory
    let platform: Platform
    let days: Int
    let lessonTitles: [String]
    let examTopics: [String]
    let pathTitle: String?
    let goalKind: LearningGoalKind
}

enum TemplateService {
    static let all: [CourseTemplate] = [
        CourseTemplate(
            id: "ios-30",
            title: "iOS 30 Days",
            details: "A month-long path through Swift fundamentals, UI, and app structure.",
            category: .programming,
            platform: .other,
            days: 30,
            lessonTitles: [
                "Swift basics", "Optionals & collections", "Functions & closures",
                "Structs vs classes", "SwiftUI layout", "State & bindings",
                "Lists & navigation", "Networking intro", "JSON decoding",
                "Local persistence", "Architecture overview", "Polish & ship checklist"
            ],
            examTopics: ["Swift syntax", "SwiftUI state", "Networking", "Persistence"],
            pathTitle: "iOS Foundations Roadmap",
            goalKind: .certificate
        ),
        CourseTemplate(
            id: "ui-design",
            title: "UI Design Starter",
            details: "Core visual design skills for product interfaces.",
            category: .design,
            platform: .skillshare,
            days: 21,
            lessonTitles: [
                "Color & contrast", "Typography hierarchy", "Spacing systems",
                "Components", "Mobile patterns", "Design critique"
            ],
            examTopics: ["Visual hierarchy", "Accessibility contrast", "Component reuse"],
            pathTitle: "Design Starter Path",
            goalKind: .hobby
        ),
        CourseTemplate(
            id: "business-essentials",
            title: "Business Essentials",
            details: "Practical business literacy for builders and freelancers.",
            category: .business,
            platform: .coursera,
            days: 14,
            lessonTitles: [
                "Value proposition", "Customer discovery", "Pricing basics",
                "Simple forecasting", "Pitch narrative"
            ],
            examTopics: ["Value prop", "Pricing", "Pitch"],
            pathTitle: nil,
            goalKind: .certificate
        ),
        CourseTemplate(
            id: "language-sprint",
            title: "Language Sprint",
            details: "Daily speaking and vocabulary blocks for fast momentum.",
            category: .language,
            platform: .other,
            days: 21,
            lessonTitles: [
                "Core phrases", "Listening drill", "Vocabulary set A",
                "Conversation practice", "Review & shadowing"
            ],
            examTopics: ["Phrases", "Listening", "Speaking confidence"],
            pathTitle: "Language Momentum Path",
            goalKind: .hobby
        )
    ]

    static func materialize(_ template: CourseTemplate, start: Date = Date()) -> (Course, LearningPath?, LearningGoal) {
        let end = Calendar.current.date(byAdding: .day, value: template.days, to: start)
        let lessons = template.lessonTitles.enumerated().map { index, title in
            Lesson(title: title, duration: 25, order: index)
        }
        let topics = template.examTopics.map { ExamTopic(title: $0) }
        let course = Course(
            title: template.title,
            description: template.details,
            platform: template.platform,
            category: template.category,
            lessons: lessons,
            startDate: start,
            endDate: end,
            examDate: end,
            examTopics: topics,
            learningGoalKinds: [template.goalKind]
        )
        let path: LearningPath? = template.pathTitle.map {
            LearningPath(title: $0, details: template.details, courseIds: [course.id])
        }
        let goal = LearningGoal(
            title: template.title,
            kind: template.goalKind,
            courseIds: [course.id],
            targetDate: end,
            isActive: true
        )
        return (course, path, goal)
    }
}
