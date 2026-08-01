//
//  ScreenTimeManager.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation
import FamilyControls

class ScreenTimeManager: ObservableObject {
    @Published var isAuthorized = false
    
    static let shared = ScreenTimeManager()
    
    private init() {}
    
    func requestScreenTimeAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await MainActor.run {
                isAuthorized = true
            }
            print("✅ Screen Time authorization granted")
        } catch {
            await MainActor.run {
                isAuthorized = false
            }
            print("❌ Screen Time authorization denied: \(error)")
        }
    }
    
    // Save self-reported screen time
    func saveScreenTime(minutes: Int) {
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: Date()).timeIntervalSince1970
        UserDefaults.standard.set(minutes, forKey: "screenTime_\(Int(dateKey))")
        print("✅ Saved screen time: \(minutes) minutes")
    }
    
    // Get today's self-reported screen time
    func getTodayScreenTime() -> Int {
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: Date()).timeIntervalSince1970
        return UserDefaults.standard.integer(forKey: "screenTime_\(Int(dateKey))")
    }
}
