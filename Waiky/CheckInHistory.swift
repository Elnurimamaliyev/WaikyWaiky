//
//  CheckInHistory.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation

struct CheckInEntry: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let mood: Int
    let sleepQuality: Int
    let nudge: String?
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

class CheckInHistoryManager {
    static let shared = CheckInHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "checkInHistory"
    
    func saveCheckIn(mood: Int, sleepQuality: Int, nudge: String?) {
        var history = getHistory()
        
        // Remove any existing check-in from today
        let calendar = Calendar.current
        history.removeAll { calendar.isDate($0.date, inSameDayAs: Date()) }
        
        // Add new check-in
        let entry = CheckInEntry(date: Date(), mood: mood, sleepQuality: sleepQuality, nudge: nudge)
        history.append(entry)
        
        // Keep only last 30 days
        history = Array(history.suffix(30))
        
        // Save
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }
    
    func getHistory() -> [CheckInEntry] {
        guard let data = userDefaults.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([CheckInEntry].self, from: data) else {
            return []
        }
        return history.sorted { $0.date < $1.date }
    }
    
    func getLastSevenDays() -> [CheckInEntry] {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return getHistory().filter { $0.date >= sevenDaysAgo }
    }
}
