//
//  HomeView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI
import EventKit

struct HomeView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var healthManager = HealthManager()
    @State private var heartRate: Double? = nil
    @State private var sleepHours: Double? = nil
    @State private var showCheckIn = false
    @State private var showProfile = false
    @State private var showEditSleep = false
    @State private var showAIChat = false
    @State private var checkInHistory: [CheckInEntry] = []
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var heartRateSimulator = HeartRateSimulator.shared
    
    // New feature states
    @State private var todayScreenTimeMinutes: Int = 0
    @State private var showScreenTimeEditor = false
    @State private var showHabitTracker = false
    @State private var showPremium = false
    @State private var todayEvents: [EKEvent] = []
    @State private var calendarAccessGranted = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                    // Greeting
                    HStack {
                        Text("Good morning, \(userName) 👋")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Health Snapshot
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Today's Health")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                showEditSleep = true
                            } label: {
                                Text("Edit Sleep")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            if let hr = heartRate {
                                VStack(alignment: .leading) {
                                    Text("\(Int(hr))")
                                        .font(.title)
                                        .bold()
                                    Text("BPM")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text("--")
                                        .font(.title)
                                        .bold()
                                    Text("BPM")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            if let sleep = sleepHours {
                                VStack(alignment: .leading) {
                                    Text(String(format: "%.1f", sleep))
                                        .font(.title)
                                        .bold()
                                    Text("Hours Sleep")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text("--")
                                        .font(.title)
                                        .bold()
                                    Text("Hours Sleep")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Weekly Mood Chart
                    WeeklyMoodChart(entries: checkInHistory)
                    
                    // Today's Nudge
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Nudge")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        if let nudge = getTodaysNudge() {
                            Text(nudge)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                        } else {
                            Text("No check-in yet today")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showCheckIn = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Check In Now")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                        }
                        .buttonStyle(LiquidGlassButtonStyle(accentColor: .blue))
                        
                        Button(action: {
                            // TODO: Navigate to focus timer
                            print("Focus Session tapped")
                        }) {
                            HStack {
                                Image(systemName: "timer")
                                Text("Focus Session")
                                    .font(.headline)
                            }
                            .foregroundColor(.purple)
                        }
                        .buttonStyle(LiquidGlassButtonStyle(accentColor: .purple))
                    }
                    
                    // NEW FEATURE 1: Screen Time Card
                    ScreenTimeCard(
                        minutes: todayScreenTimeMinutes,
                        onTap: { showScreenTimeEditor = true }
                    )
                    
                    // NEW FEATURE 2: Habit Tracker Card
                    HabitCard(onTap: { showHabitTracker = true })
                    
                    // NEW FEATURE 3: Today's Schedule Card
                    CalendarCard(events: todayEvents, hasAccess: calendarAccessGranted)
                    
                    // NEW FEATURE 4: Premium Card
                    PremiumCard(onTap: { showPremium = true })
                }
                .padding()
            }
            .navigationTitle("Waiky")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .onAppear {
                loadHealthData()
                loadCheckInHistory()
                notificationManager.requestPermission()
                heartRateSimulator.startSimulation()
                
                // Load new feature data
                loadScreenTime()
                loadCalendarEvents()
            }
            .sheet(isPresented: $showCheckIn, onDismiss: {
                // Reload history when check-in is dismissed
                loadCheckInHistory()
            }) {
                CheckInView()
            }
            .sheet(isPresented: $showAIChat) {
                AIChatView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showEditSleep) {
                EditSleepView(currentSleep: sleepHours ?? 0) { newValue in
                    sleepHours = newValue
                    // Reload health data to get the saved value from HealthKit
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        loadHealthData()
                    }
                }
            }
            .sheet(isPresented: $showScreenTimeEditor) {
                ScreenTimeEditorView(minutes: $todayScreenTimeMinutes)
            }
            .sheet(isPresented: $showHabitTracker) {
                HabitTrackerView()
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
            .onChange(of: notificationManager.shouldShowCheckIn) { _, newValue in
                if newValue {
                    showCheckIn = true
                    notificationManager.shouldShowCheckIn = false
                }
            }
            .onDisappear {
                heartRateSimulator.stopSimulation()
            }
            .refreshable {
                loadHealthData()
            }
        }
        
        // Floating Action Button - Always visible in bottom-right corner
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showAIChat = true
                }) {
                    Image("Icons")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    }
    
    private func loadHealthData() {
        healthManager.requestAuthorization { success in
            if success {
                healthManager.fetchLatestHeartRate { hr in
                    DispatchQueue.main.async {
                        heartRate = hr
                    }
                }
                healthManager.fetchLastNightSleepHours { sleep in
                    DispatchQueue.main.async {
                        sleepHours = sleep
                    }
                }
            }
        }
    }
    
    private func loadCheckInHistory() {
        checkInHistory = CheckInHistoryManager.shared.getLastSevenDays()
    }
    
    private func getTodaysNudge() -> String? {
        guard let lastNudge = UserDefaults.standard.string(forKey: "lastNudge"),
              let lastNudgeDate = UserDefaults.standard.object(forKey: "lastNudgeDate") as? Date else {
            return nil
        }
        
        // Check if the nudge is from today
        let calendar = Calendar.current
        if calendar.isDateInToday(lastNudgeDate) {
            return lastNudge
        }
        
        return nil
    }
    
    // NEW FEATURE HELPERS
    
    private func loadScreenTime() {
        todayScreenTimeMinutes = ScreenTimeManager.shared.getTodayScreenTime()
    }
    
    private func loadCalendarEvents() {
        Task {
            let granted = await CalendarManager.shared.requestCalendarAccess()
            calendarAccessGranted = granted
            
            if granted {
                todayEvents = await CalendarManager.shared.fetchTodayEvents()
            }
        }
    }
}

// MARK: - Screen Time Card

struct ScreenTimeCard: View {
    let minutes: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Screen Time Today")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Log") {
                    onTap()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            let formatted = ScreenTimeManager.shared.formatScreenTime(minutes)
            let progress = ScreenTimeManager.shared.screenTimeProgress(minutes)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatted)
                        .font(.title2)
                        .bold()
                    Text("Goal: 3 hrs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progress > 1.0 ? Color.red : Color.green,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .bold()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Habit Card

struct HabitCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Habits")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                let completion = HabitTrackerView.getTodayCompletion()
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(completion.completed)/\(completion.total) done today")
                            .font(.title3)
                            .bold()
                        
                        if completion.completed == completion.total && completion.total > 0 {
                            Text("🎉 All habits complete!")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Text("Tap to track your habits")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Card

struct CalendarCard: View {
    let events: [EKEvent]
    let hasAccess: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Schedule")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                if !hasAccess {
                    HStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .foregroundStyle(.orange)
                        Text("Calendar access not granted")
                            .font(.subheadline)
                    }
                    .padding()
                } else if events.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text("No events today")
                            .font(.subheadline)
                    }
                    .padding()
                } else {
                    ForEach(events.prefix(3), id: \.eventIdentifier) { event in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title ?? "Untitled")
                                    .font(.subheadline)
                                    .bold()
                                Text(CalendarManager.shared.formatEventTime(event))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        if event.eventIdentifier != events.prefix(3).last?.eventIdentifier {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                    
                    if events.count > 3 {
                        Text("+\(events.count - 3) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Premium Card

struct PremiumCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lock.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Waiky Premium")
                            .font(.headline)
                            .bold()
                        Text("Unlock trends, unlimited AI chat, and custom habits")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Text("€4.99/mo")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.blue)
                    
                    Spacer()
                    
                    Text("Upgrade")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Screen Time Editor Sheet

struct ScreenTimeEditorView: View {
    @Binding var minutes: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Log your screen time today")
                    .font(.headline)
                
                Text("(self-reported for now)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(ScreenTimeManager.shared.formatScreenTime(minutes))
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.blue)
                
                Slider(value: Binding(
                    get: { Double(minutes) },
                    set: { minutes = Int($0) }
                ), in: 0...600, step: 15)
                    .padding(.horizontal)
                
                HStack {
                    Text("0 min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("10 hrs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Save") {
                    ScreenTimeManager.shared.saveTodayScreenTime(minutes)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Screen Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
