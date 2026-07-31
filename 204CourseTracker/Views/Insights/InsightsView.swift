//
//  InsightsView.swift
//  204CourseTracker
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel: InsightsViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: InsightsViewModel(store: store))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.insights) { insight in
                        InsightCell(insight: insight)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
