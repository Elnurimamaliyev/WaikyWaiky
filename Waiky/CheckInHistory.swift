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
    
    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

class CheckInHistoryManager {
    static let shared = CheckInHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "checkInHistory"
    
    func saveCheckIn(mood: Int?, sleepQuality: Int?, nudge: String?) {
        var history = getHistory()
        
        // Allow multiple check-ins per day - don't remove existing ones
        
        // Add new check-in (use 0 for skipped values)
        let entry = CheckInEntry(date: Date(), mood: mood ?? 0, sleepQuality: sleepQuality ?? 0, nudge: nudge)
        history.append(entry)
        
        // Keep only last 50 entries
        history = Array(history.suffix(50))
        
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
    
    func getRecentEntries(limit: Int = 20) -> [CheckInEntry] {
        let all = getHistory()
        return Array(all.suffix(limit))
    }
}
