//
//  Category.swift
//  204CourseTracker
//

import Foundation

enum CourseCategory: String, Codable, CaseIterable, Identifiable {
    case programming
    case design
    case business
    case language
    case science
    case math
    case art
    case music
    case fitness
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .programming: return "Programming"
        case .design: return "Design"
        case .business: return "Business"
        case .language: return "Languages"
        case .science: return "Science"
        case .math: return "Math"
        case .art: return "Art"
        case .music: return "Music"
        case .fitness: return "Fitness"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .programming: return "chevron.left.forwardslash.chevron.right"
        case .design: return "paintbrush"
        case .business: return "briefcase"
        case .language: return "globe"
        case .science: return "atom"
        case .math: return "function"
        case .art: return "paintpalette"
        case .music: return "music.note"
        case .fitness: return "figure.run"
        case .other: return "square.grid.2x2"
        }
    }
}
