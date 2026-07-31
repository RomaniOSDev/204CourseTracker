//
//  MoodReflectionSheet.swift
//  204CourseTracker
//

import SwiftUI

struct MoodReflectionSheet: View {
    @Binding var mood: MoodLevel
    @Binding var energy: EnergyLevel
    @Binding var note: String
    var onSave: () -> Void
    var onSkip: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("How do you feel?") {
                    Picker("Mood", selection: $mood) {
                        ForEach(MoodLevel.allCases) { level in
                            Label(level.displayName, systemImage: level.systemImage).tag(level)
                        }
                    }
                    Picker("Energy", selection: $energy) {
                        ForEach(EnergyLevel.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                }
                Section("Optional note") {
                    TextField("Quick reflection", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("After Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip", action: onSkip)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
