//
//  ExportImportService.swift
//  204CourseTracker
//

import Foundation

enum ExportFormat: String, CaseIterable, Identifiable {
    case json
    case csv
    case markdown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        case .markdown: return "Markdown"
        }
    }

    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        case .markdown: return "md"
        }
    }

    var contentTypeUTType: String {
        switch self {
        case .json: return "public.json"
        case .csv: return "public.comma-separated-values-text"
        case .markdown: return "net.daringfireball.markdown"
        }
    }
}

enum ExportImportService {
    static func makeBackup(from storeSnapshot: AppBackup) -> AppBackup {
        var backup = storeSnapshot
        backup.version = AppBackup.currentVersion
        backup.exportedAt = Date()
        return backup
    }

    static func exportData(_ backup: AppBackup, format: ExportFormat) throws -> Data {
        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            return try encoder.encode(backup)
        case .csv:
            return csv(from: backup).data(using: .utf8) ?? Data()
        case .markdown:
            return markdown(from: backup).data(using: .utf8) ?? Data()
        }
    }

    static func importJSON(_ data: Data) throws -> AppBackup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(AppBackup.self, from: data)
        } catch {
            let fallback = JSONDecoder()
            return try fallback.decode(AppBackup.self, from: data)
        }
    }

    private static func csv(from backup: AppBackup) -> String {
        var lines = ["type,id,title,extra,progress,minutes"]
        for course in backup.courses {
            let title = escape(course.title)
            lines.append("course,\(course.id.uuidString),\(title),\(course.category.displayName),\(course.progressPercent),\(course.totalMinutes)")
            for lesson in course.sortedLessons {
                lines.append("lesson,\(lesson.id.uuidString),\(escape(lesson.title)),\(course.id.uuidString),\(lesson.isCompleted ? 100 : 0),\(lesson.duration ?? 0)")
            }
        }
        for note in backup.notes {
            lines.append("note,\(note.id.uuidString),\(escape(note.title)),\(note.courseId.uuidString),0,0")
        }
        for session in backup.focusSessions {
            lines.append("focus,\(session.id.uuidString),session,\(session.courseId?.uuidString ?? ""),0,\(session.actualMinutes)")
        }
        return lines.joined(separator: "\n")
    }

    private static func markdown(from backup: AppBackup) -> String {
        var md = "# Learning Progress Export\n\n"
        md += "Exported: \(backup.exportedAt.formatted(date: .abbreviated, time: .shortened))\n\n"
        md += "## Summary\n"
        md += "- Courses: \(backup.courses.count)\n"
        md += "- Notes: \(backup.notes.count)\n"
        md += "- Focus sessions: \(backup.focusSessions.count)\n"
        md += "- Flashcards: \(backup.flashcards.count)\n"
        md += "- Daily goal: \(backup.studyGoals.dailyLessonsGoal) lessons / \(backup.studyGoals.dailyMinutesGoal) min\n\n"

        md += "## Courses\n"
        for course in backup.courses {
            md += "### \(course.title)\n"
            md += "- Category: \(course.category.displayName)\n"
            md += "- Platform: \(course.platform.displayName)\n"
            md += "- Progress: \(course.progressPercent)%\n"
            if let exam = course.examDate {
                md += "- Exam: \(exam.formatted(date: .abbreviated, time: .omitted)) (readiness \(course.examReadinessPercent)%)\n"
            }
            if !course.lessons.isEmpty {
                md += "- Lessons:\n"
                for lesson in course.sortedLessons {
                    let mark = lesson.isCompleted ? "x" : " "
                    let mins = lesson.duration.map { " (\($0) min)" } ?? ""
                    md += "  - [\(mark)] \(lesson.title)\(mins)\n"
                }
            }
            md += "\n"
        }
        return md
    }

    private static func escape(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
