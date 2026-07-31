//
//  HomeWidgets.swift
//  204CourseTracker
//

import SwiftUI

// MARK: - Hero

struct HomeHeroWidget: View {
    let streak: Int
    let todayLessons: Int
    let todayMinutes: Int
    let insight: String?
    var onStudyPlan: () -> Void
    var onFocus: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 210)
                .clipped()

            AppGradients.heroScrim

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    StatusBadge(text: "\(streak) day streak", tint: AppColors.accent)
                    Text("\(todayLessons) lessons today")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())
                }

                Text("Keep learning today")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text(insight ?? "A focused session beats a perfect plan.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Button("Study Plan", action: onStudyPlan)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.white)
                        .clipShape(Capsule())

                    Button("Start Focus", action: onFocus)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(AppColors.accent.opacity(0.95))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))

                    Spacer(minLength: 0)

                    Text("\(todayMinutes) min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(18)
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        .compositingGroup()
        .shadow(color: AppDepth.floating.shadowColor, radius: AppDepth.floating.radius, x: 0, y: AppDepth.floating.y)
    }
}

// MARK: - Image widgets

struct HomeImageWidget: View {
    let title: String
    let subtitle: String
    let imageName: String
    let value: String
    var tint: Color = AppColors.accent
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 96)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    Text(value)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppGradients.brandHorizontal)
                        .clipShape(Capsule())
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppGradients.cardFace)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), tint.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .compositingGroup()
            .shadow(color: AppDepth.raised.shadowColor, radius: AppDepth.raised.radius, x: 0, y: AppDepth.raised.y)
        }
        .buttonStyle(.plain)
    }
}

struct HomeProgressWidget: View {
    let progress: Double
    let courses: Int
    let completed: Int
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(AppColors.background, lineWidth: 10)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: min(max(progress, 0), 1))
                        .stroke(
                            AppGradients.brand,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Overall Progress")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(completed) of \(courses) courses completed")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    ProgressBarView(progress: progress, height: 8, showsGlow: true)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            }
            .softCard()
        }
        .buttonStyle(.plain)
    }
}

struct HomeQuickStatWidget: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = AppColors.accent

    var body: some View {
        HStack(spacing: 10) {
            IconBadgeView(systemImage: systemImage, tint: tint, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .elevatedSurface(radius: AppRadius.md, depth: .raised, tint: tint)
    }
}

struct HomeContinueCourseWidget: View {
    let course: Course
    var onTap: () -> Void
    var onFocus: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                IconBadgeView(systemImage: course.category.systemImage, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Continue")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.accent)
                    Text(course.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                }
                Spacer()
                Text("\(course.progressPercent)%")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.secondary)
            }

            ProgressBarView(progress: course.progress, height: 9)

            HStack(spacing: 10) {
                Button("Open", action: onTap)
                    .buttonStyle(PrimaryButtonStyle(filled: false))
                Button("Focus", action: onFocus)
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .softCard()
    }
}

struct HomeInsightBanner: View {
    let text: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                IconBadgeView(systemImage: "lightbulb.fill", tint: AppColors.secondary, size: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Smart Insight")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.secondary)
                    Text(text)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            }
            .softCard(padding: 14)
        }
        .buttonStyle(.plain)
    }
}
