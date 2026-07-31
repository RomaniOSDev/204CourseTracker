//
//  Platform.swift
//  204CourseTracker
//

import Foundation

enum Platform: String, Codable, CaseIterable, Identifiable {
    case coursera
    case udemy
    case edx
    case skillshare
    case youtube
    case stepik
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .coursera: return "Coursera"
        case .udemy: return "Udemy"
        case .edx: return "edX"
        case .skillshare: return "Skillshare"
        case .youtube: return "YouTube"
        case .stepik: return "Stepik"
        case .other: return "Other"
        }
    }
}
