//
//  NotesView.swift
//  204CourseTracker
//

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel: NotesViewModel

    init(store: CourseStore, courseId: UUID) {
        _viewModel = StateObject(wrappedValue: NotesViewModel(store: store, courseId: courseId))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            if viewModel.notes.isEmpty {
                ScrollView {
                    EmptyStateView(
                        systemImage: "note.text",
                        title: "No notes yet",
                        message: "Capture ideas and key takeaways for this course.",
                        actionTitle: "Add Note"
                    ) {
                        viewModel.openAddSheet()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
                .clearScrollBackground()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.notes) { note in
                            NoteCell(note: note)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation { viewModel.delete(note) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.notes.map(\.id))
                }
                .clearScrollBackground()
            }
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Note") { viewModel.openAddSheet() }
                    Button("Create Flashcards") { viewModel.createFlashcards() }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            NavigationStack {
                Form {
                    Section("Title") {
                        TextField("Note title", text: $viewModel.newTitle)
                    }
                    Section("Content") {
                        TextField("Write your note…", text: $viewModel.newContent, axis: .vertical)
                            .lineLimit(5...12)
                    }
                }
                .navigationTitle("New Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { viewModel.showAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { viewModel.addNote() }
                            .fontWeight(.semibold)
                    }
                }
                .alert(
                    "Missing Information",
                    isPresented: Binding(
                        get: { viewModel.validationMessage != nil },
                        set: { if !$0 { viewModel.validationMessage = nil } }
                    )
                ) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.validationMessage ?? "")
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
