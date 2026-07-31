//
//  StatCardView.swift
//  204CourseTracker
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = AppColors.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            IconBadgeView(systemImage: systemImage, tint: tint, size: 36)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .elevatedSurface(radius: AppRadius.md, depth: .raised, tint: tint)
    }
}
