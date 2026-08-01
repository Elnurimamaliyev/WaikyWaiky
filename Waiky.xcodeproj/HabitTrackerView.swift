//
//  HabitTrackerView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct Habit: Codable, Identifiable {
    let id: UUID
    let name: String
    var isDone: Bool
    
    init(id: UUID = UUID(), name: String, isDone: Bool = false) {
        self.id = id
        self.name = name
        self.isDone = isDone
    }
}

struct HabitTrackerView: View {
    @State private var habits: [Habit] = []
    @Environment(\.dismiss) var dismiss
    
    private let defaultHabits = [
        "Morning check-in",
        "No phone first 30 min",
        "Movement break",
        "Wind down before bed"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($habits) { $habit in
                    HStack {
                        Button(action: {
                            habit.isDone.toggle()
                            saveHabits()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: habit.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(habit.isDone ? .green : .gray)
                                
                                Text(habit.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .strikethrough(habit.isDone)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Daily Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadHabits()
            }
        }
    }
    
    private func loadHabits() {
        let dateKey = getTodayDateKey()
        
        if let data = UserDefaults.standard.data(forKey: "habits_\(dateKey)"),
           let savedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = savedHabits
        } else {
            // Create default habits for today
            habits = defaultHabits.map { Habit(name: $0) }
            saveHabits()
        }
    }
    
    private func saveHabits() {
        let dateKey = getTodayDateKey()
        
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habits_\(dateKey)")
        }
    }
    
    private func getTodayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    HabitTrackerView()
}
