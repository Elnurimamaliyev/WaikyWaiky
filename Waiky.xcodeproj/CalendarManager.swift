//
//  CalendarManager.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation
import EventKit

@Observable
class CalendarManager {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    
    private init() {}
    
    /// Request calendar access authorization
    func requestCalendarAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            print(granted ? "✅ Calendar access granted" : "❌ Calendar access denied")
            return granted
        } catch {
            print("❌ Calendar authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Fetch today's events sorted by start time
    func fetchTodayEvents() async -> [EKEvent] {
        // Check authorization status first
        let status = EKEventStore.authorizationStatus(for: .event)
        
        guard status == .fullAccess else {
            print("⚠️ Calendar access not granted, status: \(status.rawValue)")
            return []
        }
        
        // Create date range for today
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        // Create predicate and fetch events
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
            .filter { !$0.isAllDay } // Filter out all-day events
            .sorted { $0.startDate < $1.startDate } // Sort by start time
        
        print("✅ Fetched \(events.count) events for today")
        return events
    }
    
    /// Format event time for display
    func formatEventTime(_ event: EKEvent) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
    
    /// Check if today is a "busy day" (more than 4 events)
    func isBusyDay(events: [EKEvent]) -> Bool {
        return events.count > 4
    }
}
