//
//  AppCoordinator.swift
//  204CourseTracker
//

import Combine
import SwiftUI

enum AppRoute: Hashable {
    case courseList
    case courseDetail(UUID)
    case addCourse
    case editCourse(UUID)
    case notes(UUID)
    case statistics
    case studyPlan
    case focusTimer(UUID?)
    case flashcards
    case examMode(UUID)
    case learningPaths
    case insights
    case dataTools
    case templates
    case goals
    case settings
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    @ViewBuilder
    func destination(for route: AppRoute, store: CourseStore) -> some View {
        switch route {
        case .courseList:
            CourseListView(store: store, coordinator: self)
        case .courseDetail(let id):
            CourseDetailView(store: store, courseId: id, coordinator: self)
        case .addCourse:
            CourseFormView(store: store, mode: .add, coordinator: self)
        case .editCourse(let id):
            CourseFormView(store: store, mode: .edit(id), coordinator: self)
        case .notes(let id):
            NotesView(store: store, courseId: id)
        case .statistics:
            StatisticsView(store: store)
        case .studyPlan:
            StudyPlanView(store: store)
        case .focusTimer(let courseId):
            FocusTimerView(store: store, courseId: courseId)
        case .flashcards:
            FlashcardsView(store: store)
        case .examMode(let id):
            ExamModeView(store: store, courseId: id)
        case .learningPaths:
            LearningPathView(store: store)
        case .insights:
            InsightsView(store: store)
        case .dataTools:
            DataToolsView(store: store)
        case .templates:
            TemplatesView(store: store)
        case .goals:
            GoalsView(store: store)
        case .settings:
            SettingsView()
        }
    }
}
