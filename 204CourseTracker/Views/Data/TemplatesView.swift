//
//  TemplatesView.swift
//  204CourseTracker
//

import SwiftUI

struct TemplatesView: View {
    @StateObject private var viewModel: TemplatesViewModel

    init(store: CourseStore) {
        _viewModel = StateObject(wrappedValue: TemplatesViewModel(store: store))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.templates) { template in
                        TemplateCardCell(template: template) {
                            viewModel.apply(template)
                        }
                    }
                    if let status = viewModel.statusMessage {
                        Text(status)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.success)
                            .softCard(padding: 12, radius: AppRadius.sm)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Templates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
