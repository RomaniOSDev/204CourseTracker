//
//  ProgressBarView.swift
//  204CourseTracker
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    var height: CGFloat = 8
    /// Soft glow looks nice but is costly in long lists — off by default.
    var showsGlow: Bool = false

    var body: some View {
        GeometryReader { geo in
            let width = max(0, geo.size.width * min(max(progress, 0), 1))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.background)

                Capsule()
                    .fill(AppGradients.brandHorizontal)
                    .frame(width: width)
                    .shadow(
                        color: showsGlow ? AppColors.accent.opacity(0.28) : .clear,
                        radius: showsGlow ? 3 : 0,
                        x: 0,
                        y: 0
                    )
            }
        }
        .frame(height: height)
        // Linear is cheaper than spring during scrolling updates
        .animation(.easeOut(duration: 0.2), value: progress)
    }
}
