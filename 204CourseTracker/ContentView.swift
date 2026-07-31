//
//  ContentView.swift
//  204CourseTracker
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = CourseStore()
    @StateObject private var coordinator = AppCoordinator()
    @State private var showOnboarding = !OnboardingViewModel.hasCompletedOnboarding

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                NavigationStack(path: $coordinator.path) {
                    HomeView(store: store, coordinator: coordinator)
                        .navigationDestination(for: AppRoute.self) { route in
                            coordinator.destination(for: route, store: store)
                        }
                }
                .transition(.opacity)
            }
        }
        .tint(AppColors.accent)
        .animation(.easeInOut(duration: 0.3), value: showOnboarding)
    }
}

#Preview {
    ContentView()
}
