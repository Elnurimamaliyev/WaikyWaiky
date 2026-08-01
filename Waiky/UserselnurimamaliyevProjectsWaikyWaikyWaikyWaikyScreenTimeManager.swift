//
//  ScreenTimeManager.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation
import FamilyControls

@Observable
class ScreenTimeManager {
    static let shared = ScreenTimeManager()
    
    private let authorizationCenter = AuthorizationCenter.shared
    
    private init() {}
    
    /// Request FamilyControls authorization for screen time access
    func requestScreenTimeAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            print("✅ Screen Time authorization granted")
        } catch {
            print("❌ Screen Time authorization failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get today's screen time from UserDefaults (self-reported)
    func getTodayScreenTime() -> Int {
        let key = "todayScreenTime"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    /// Save today's screen time to UserDefaults (self-reported)
    func saveTodayScreenTime(_ minutes: Int) {
        let key = "todayScreenTime"
        UserDefaults.standard.set(minutes, forKey: key)
        print("✅ Saved screen time: \(minutes) minutes")
    }
    
    /// Format minutes into hours and minutes string
    func formatScreenTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours) hr \(mins) min"
        } else {
            return "\(mins) min"
        }
    }
    
    /// Calculate progress against goal (3 hours = 180 minutes)
    func screenTimeProgress(_ minutes: Int) -> Double {
        let goalMinutes = 180.0 // 3 hours
        return min(Double(minutes) / goalMinutes, 1.0)
    }
}
