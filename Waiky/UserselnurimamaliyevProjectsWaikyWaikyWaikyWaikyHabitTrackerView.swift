//
//  HabitTrackerView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
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
    
    // Default habits
    private let defaultHabits = [
        "Morning check-in",
        "No phone first 30 min",
        "Movement break",
        "Wind down before bed"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($habits) { $habit in
                        HStack {
                            Button {
                                habit.isDone.toggle()
                                saveHabits()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: habit.isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(habit.isDone ? .green : .gray)
                                    
                                    Text(habit.name)
                                        .foregroundStyle(habit.isDone ? .secondary : .primary)
                                        .strikethrough(habit.isDone)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                        }
                    }
                } header: {
                    Text("Today's Habits")
                } footer: {
                    let completed = habits.filter { $0.isDone }.count
                    let total = habits.count
                    Text("\(completed) of \(total) completed")
                }
            }
            .navigationTitle("Habit Tracker")
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
        let today = getTodayKey()
        
        if let data = UserDefaults.standard.data(forKey: today),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
            print("✅ Loaded habits for \(today): \(habits.count) habits")
        } else {
            // Initialize with default habits for today
            habits = defaultHabits.map { Habit(name: $0, isDone: false) }
            saveHabits()
            print("✅ Initialized default habits for \(today)")
        }
    }
    
    private func saveHabits() {
        let today = getTodayKey()
        
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: today)
            print("✅ Saved habits for \(today)")
        }
    }
    
    private func getTodayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "habits-\(formatter.string(from: Date()))"
    }
}

// Extension to get habit completion for HomeView
extension HabitTrackerView {
    static func getTodayCompletion() -> (completed: Int, total: Int) {
        let today = getTodayKeyStatic()
        
        if let data = UserDefaults.standard.data(forKey: today),
           let habits = try? JSONDecoder().decode([Habit].self, from: data) {
            let completed = habits.filter { $0.isDone }.count
            return (completed, habits.count)
        } else {
            // Return 0/4 if no habits saved yet
            return (0, 4)
        }
    }
    
    private static func getTodayKeyStatic() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "habits-\(formatter.string(from: Date()))"
    }
}

#Preview {
    HabitTrackerView()
}
