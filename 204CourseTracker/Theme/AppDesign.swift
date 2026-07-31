//
//  AppDesign.swift
//  204CourseTracker
//

import SwiftUI

// MARK: - Tokens

enum AppSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 18
    static let xl: CGFloat = 24
}

enum AppRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 18
    static let xl: CGFloat = 24
}

/// Precomputed gradients — avoid reallocating LinearGradient on every body pass.
enum AppGradients {
    static let brand = LinearGradient(
        colors: [AppColors.accent, AppColors.secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let brandHorizontal = LinearGradient(
        colors: [AppColors.accent, AppColors.secondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let screenWash = LinearGradient(
        colors: [
            AppColors.accent.opacity(0.14),
            AppColors.secondary.opacity(0.06),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardFace = LinearGradient(
        colors: [
            AppColors.surfaceElevated,
            AppColors.surface
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardSheen = LinearGradient(
        colors: [
            Color.white.opacity(0.55),
            Color.white.opacity(0.08),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .center
    )

    static let cardSheenDark = LinearGradient(
        colors: [
            Color.white.opacity(0.10),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .center
    )

    static let heroScrim = LinearGradient(
        colors: [Color.black.opacity(0.02), Color.black.opacity(0.58)],
        startPoint: .top,
        endPoint: .bottom
    )

    static func tintWash(_ tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint.opacity(0.24), tint.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum AppDepth {
    case flat
    case raised
    case floating

    var shadowColor: Color {
        switch self {
        case .flat: return Color.black.opacity(0.04)
        case .raised: return Color.black.opacity(0.08)
        case .floating: return AppColors.accent.opacity(0.18)
        }
    }

    var radius: CGFloat {
        switch self {
        case .flat: return 4
        case .raised: return 10
        case .floating: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .flat: return 2
        case .raised: return 5
        case .floating: return 8
        }
    }
}

// MARK: - Background (no blur — rasterized once)

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppColors.background
            AppGradients.screenWash

            // Soft volume blobs without blur (cheap ellipses)
            Ellipse()
                .fill(AppColors.accent.opacity(0.10))
                .frame(width: 320, height: 220)
                .offset(x: 130, y: -260)

            Ellipse()
                .fill(AppColors.secondary.opacity(0.08))
                .frame(width: 280, height: 200)
                .offset(x: -140, y: 360)

            // Thin top highlight strip for depth
            LinearGradient(
                colors: [Color.white.opacity(0.18), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Rasterize first, then expand — drawingGroup after ignoresSafeArea
        // clips back to the safe area and leaves empty strips top/bottom.
        .drawingGroup(opaque: true)
        .ignoresSafeArea()
    }
}

// MARK: - Surfaces

struct SoftCardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.md
    var radius: CGFloat = AppRadius.lg
    var depth: AppDepth = .raised
    var showSheen: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(AppGradients.cardFace)
                        .shadow(color: depth.shadowColor, radius: depth.radius, x: 0, y: depth.y)

                    if showSheen {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(colorScheme == .dark ? AppGradients.cardSheenDark : AppGradients.cardSheen)
                            .mask(
                                LinearGradient(
                                    colors: [.white, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .allowsHitTesting(false)
                    }

                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.12 : 0.70),
                                    AppColors.accent.opacity(0.14),
                                    AppColors.secondary.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
    }
}

struct ElevatedSurfaceModifier: ViewModifier {
    var radius: CGFloat = AppRadius.md
    var depth: AppDepth = .flat
    var tint: Color = AppColors.accent

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(AppGradients.cardFace)
                        .shadow(color: depth.shadowColor, radius: depth.radius, x: 0, y: depth.y)

                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.55),
                                    tint.opacity(0.16)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
    }
}

extension View {
    func softCard(
        padding: CGFloat = AppSpacing.md,
        radius: CGFloat = AppRadius.lg,
        depth: AppDepth = .raised,
        showSheen: Bool = true
    ) -> some View {
        modifier(SoftCardModifier(padding: padding, radius: radius, depth: depth, showSheen: showSheen))
    }

    func elevatedSurface(
        radius: CGFloat = AppRadius.md,
        depth: AppDepth = .flat,
        tint: Color = AppColors.accent
    ) -> some View {
        modifier(ElevatedSurfaceModifier(radius: radius, depth: depth, tint: tint))
    }

    func screenContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            AppBackgroundView()
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shared chrome

struct SectionHeaderView: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.accent)
            }
        }
    }
}

struct IconBadgeView: View {
    let systemImage: String
    var tint: Color = AppColors.accent
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(AppGradients.tintWash(tint))
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
            Image(systemName: systemImage)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        // Tiny depth without nested card shadows
        .shadow(color: tint.opacity(0.18), radius: 4, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let text: String
    var tint: Color = AppColors.accent
    var filled: Bool = true

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(filled ? Color.white : tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                if filled {
                    Capsule().fill(AppGradients.brandHorizontal)
                } else {
                    Capsule().fill(tint.opacity(0.12))
                }
            }
            .overlay {
                if !filled {
                    Capsule().stroke(tint.opacity(0.25), lineWidth: 1)
                }
            }
    }
}

struct MetricChip: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(AppColors.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(AppColors.background)
                .overlay(Capsule().stroke(AppColors.accent.opacity(0.10), lineWidth: 1))
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var filled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(filled ? Color.white : AppColors.accent)
            .background {
                if filled {
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppGradients.brandHorizontal)
                        .shadow(
                            color: configuration.isPressed ? .clear : AppColors.accent.opacity(0.28),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppGradients.cardFace)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .stroke(AppColors.accent.opacity(0.35), lineWidth: 1)
                        )
                }
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            // Short animation only on press — cheap
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct FilterChipView: View {
    let title: String
    let isActive: Bool
    var showsChevron: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            if showsChevron {
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(isActive ? Color.white : AppColors.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            if isActive {
                Capsule()
                    .fill(AppGradients.brandHorizontal)
                    .shadow(color: AppColors.accent.opacity(0.22), radius: 5, x: 0, y: 2)
            } else {
                Capsule()
                    .fill(AppGradients.cardFace)
            }
        }
        .overlay(
            Capsule().stroke(AppColors.accent.opacity(isActive ? 0 : 0.15), lineWidth: 1)
        )
    }
}
