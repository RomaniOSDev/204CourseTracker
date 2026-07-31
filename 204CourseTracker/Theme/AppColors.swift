//
//  AppColors.swift
//  204CourseTracker
//

import SwiftUI
import UIKit

enum AppColors {
    static let accent = Color(red: 2 / 255, green: 175 / 255, blue: 239 / 255)
    static let secondary = Color(red: 1 / 255, green: 140 / 255, blue: 208 / 255)

    static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.08, blue: 0.10, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })

    static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.14, blue: 0.17, alpha: 1)
            : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    })

    /// Slightly brighter than surface for card gradient “lift”.
    static let surfaceElevated = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.18, blue: 0.22, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })

    static let textPrimary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1)
            : UIColor(red: 26 / 255, green: 26 / 255, blue: 26 / 255, alpha: 1)
    })

    static let textSecondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.55, green: 0.62, blue: 0.70, alpha: 1)
            : UIColor(red: 107 / 255, green: 123 / 255, blue: 141 / 255, alpha: 1)
    })

    static let danger = Color(red: 0.90, green: 0.30, blue: 0.30)
    static let success = Color(red: 0.20, green: 0.72, blue: 0.45)
}

extension View {
    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }
}
