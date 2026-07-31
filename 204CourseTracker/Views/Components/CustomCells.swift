//
//  CustomCells.swift
//  204CourseTracker
//

import SwiftUI

// MARK: - Feature tile

struct FeatureTileCell: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var tint: Color = AppColors.accent

    var body: some View {
        HStack(spacing: 12) {
            IconBadgeView(systemImage: systemImage, tint: tint, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
        }
        .padding(12)
        .elevatedSurface(radius: AppRadius.md, depth: .raised, tint: tint)
    }
}

// MARK: - Course cell

struct CourseCardView: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadgeView(systemImage: course.category.systemImage, size: 46)

                VStack(alignment: .leading, spacing: 6) {
                    Text(course.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        MetricChip(text: course.category.displayName, systemImage: "tag")
                        MetricChip(text: course.platform.displayName, systemImage: "laptopcomputer")
                    }
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 6) {
                    if course.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppColors.accent)
                    }
                    if course.isCompleted {
                        StatusBadge(text: "Done", tint: AppColors.success)
                    } else if course.examDate != nil {
                        StatusBadge(text: "Exam", tint: AppColors.secondary, filled: false)
                    }
                }
            }

            HStack {
                Text("\(course.progressPercent)%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.secondary)
                Spacer()
                Text("\(course.completedLessonsCount)/\(course.lessons.count) lessons")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            ProgressBarView(progress: course.progress, height: 9)

            if let days = course.daysUntilExam, days >= 0 {
                Label("Exam in \(days)d · readiness \(course.examReadinessPercent)%", systemImage: "rosette")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(AppColors.secondary)
            }
        }
        .softCard(depth: .raised)
    }
}

// MARK: - Lesson row

struct LessonRowCell: View {
    let lesson: Lesson
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(lesson.isCompleted ? AppColors.success : AppColors.textSecondary)

                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .strikethrough(lesson.isCompleted, color: AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                    if let duration = lesson.duration {
                        Text("\(duration) min")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "hand.tap")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.4))
            }
            .padding(14)
            .elevatedSurface(
                radius: AppRadius.md,
                depth: .flat,
                tint: lesson.isCompleted ? AppColors.success : AppColors.accent
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Action menu cell

struct ActionMenuCell: View {
    let title: String
    let systemImage: String
    var tint: Color = AppColors.accent
    var subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            IconBadgeView(systemImage: systemImage, tint: tint, size: 38)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
        }
        .padding(12)
        .elevatedSurface(radius: AppRadius.md, depth: .raised, tint: tint)
    }
}

// MARK: - Insight cell

struct InsightCell: View {
    let insight: InsightItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadgeView(systemImage: insight.systemImage, size: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(insight.detail)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .softCard(padding: 14, radius: AppRadius.md)
    }
}

// MARK: - Note cell

struct NoteCell: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                IconBadgeView(systemImage: "note.text", size: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(3)
                }
            }
            Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary.opacity(0.8))
        }
        .softCard(padding: 14, radius: AppRadius.md)
    }
}

// MARK: - Checklist topic

struct ChecklistTopicCell: View {
    let topic: ExamTopic
    var onToggle: () -> Void
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: topic.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(topic.isCompleted ? AppColors.success : AppColors.textSecondary)
            }
            .buttonStyle(.plain)

            Text(topic.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.textPrimary)
                .strikethrough(topic.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(AppColors.danger)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .elevatedSurface(
            radius: AppRadius.sm,
            depth: .flat,
            tint: topic.isCompleted ? AppColors.success : AppColors.accent
        )
    }
}

// MARK: - Path / Goal / Template

struct PathCardCell: View {
    let path: LearningPath
    let progress: Double
    let steps: [(index: Int, title: String, unlocked: Bool)]
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadgeView(systemImage: "map", size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(path.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    if let details = path.details {
                        Text(details)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(AppColors.danger)
                }
            }

            ProgressBarView(progress: progress, height: 8)
            Text("\(Int((progress * 100).rounded()))% path complete")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppColors.secondary)

            ForEach(steps, id: \.index) { step in
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(step.unlocked ? AppColors.accent.opacity(0.15) : AppColors.background)
                            .frame(width: 28, height: 28)
                        Text("\(step.index)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(step.unlocked ? AppColors.accent : AppColors.textSecondary)
                    }
                    Text(step.title)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: step.unlocked ? "lock.open.fill" : "lock.fill")
                        .font(.caption)
                        .foregroundStyle(step.unlocked ? AppColors.success : AppColors.textSecondary)
                }
            }
        }
        .softCard()
    }
}

struct GoalCardCell: View {
    let goal: LearningGoal
    let progress: Double
    var onToggle: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconBadgeView(systemImage: goal.kind.systemImage, tint: goal.kind == .certificate ? AppColors.secondary : AppColors.accent)
                VStack(alignment: .leading, spacing: 2) {
                    StatusBadge(text: goal.kind.displayName, tint: AppColors.accent, filled: false)
                    Text(goal.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
                if !goal.isActive {
                    StatusBadge(text: "Paused", tint: AppColors.textSecondary, filled: false)
                }
            }

            ProgressBarView(progress: progress, height: 8)

            if let date = goal.targetDate {
                Label("Target \(date.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack {
                Button(goal.isActive ? "Pause" : "Activate", action: onToggle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondary)
                Spacer()
                Button("Delete", role: .destructive, action: onDelete)
                    .font(.caption.weight(.semibold))
            }
        }
        .softCard()
    }
}

struct TemplateCardCell: View {
    let template: CourseTemplate
    var onUse: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadgeView(systemImage: template.category.systemImage, size: 46)
                VStack(alignment: .leading, spacing: 6) {
                    Text(template.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(template.details)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 6) {
                MetricChip(text: template.category.displayName, systemImage: "tag")
                MetricChip(text: "\(template.days) days", systemImage: "calendar")
                MetricChip(text: template.goalKind.displayName, systemImage: template.goalKind.systemImage)
            }

            Button("Use Template", action: onUse)
                .buttonStyle(PrimaryButtonStyle())
        }
        .softCard()
    }
}

// MARK: - Streak / calendar

struct StreakHeroCell: View {
    let streak: Int
    let todayLessons: Int
    let todayMinutes: Int
    let insight: String?
    let dueFlashcards: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(AppGradients.brand)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppColors.accent.opacity(0.28), radius: 8, x: 0, y: 4)
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(streak) day streak")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Today: \(todayLessons) lessons · \(todayMinutes) min")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }

            if let insight {
                Text(insight)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.background.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            }

            if dueFlashcards > 0 {
                Label("\(dueFlashcards) flashcards waiting", systemImage: "rectangle.on.rectangle.angled")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondary)
            }
        }
        .softCard(padding: 16)
    }
}

struct CalendarDayCell: View {
    let day: DayActivity
    let goals: StudyGoalSettings

    private var fill: Color {
        if day.meets(goals: goals) { return AppColors.accent }
        if day.minutesStudied > 0 || day.lessonsCompleted > 0 { return AppColors.accent.opacity(0.35) }
        return AppColors.background
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(fill)
            .frame(height: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(AppColors.accent.opacity(0.08), lineWidth: 0.5)
            )
            .accessibilityLabel(day.dayKey)
    }
}

// MARK: - Flashcard

struct FlashcardFaceCell: View {
    let label: String
    let text: String
    let showHint: Bool

    var body: some View {
        VStack(spacing: 14) {
            StatusBadge(text: label, tint: AppColors.accent, filled: false)
            Text(text)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 150)
            if showHint {
                Text("Tap to flip")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(AppGradients.cardFace)
                .shadow(color: AppDepth.floating.shadowColor, radius: AppDepth.floating.radius, x: 0, y: AppDepth.floating.y)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .stroke(AppGradients.brand, lineWidth: 1.2)
                .opacity(0.45)
        }
    }
}
