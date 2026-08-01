//
//  CalendarManager.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation
import EventKit

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var isAuthorized = false
    
    static let shared = CalendarManager()
    
    private init() {}
    
    func requestCalendarAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                isAuthorized = granted
            }
            print(granted ? "✅ Calendar access granted" : "❌ Calendar access denied")
        } catch {
            await MainActor.run {
                isAuthorized = false
            }
            print("❌ Calendar authorization error: \(error)")
        }
    }
    
    func fetchTodayEvents() -> [EKEvent] {
        guard isAuthorized else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        // Filter to upcoming events and sort by start time
        let now = Date()
        let upcomingEvents = events.filter { $0.startDate >= now }
        
        return upcomingEvents.sorted { $0.startDate < $1.startDate }
    }
}
