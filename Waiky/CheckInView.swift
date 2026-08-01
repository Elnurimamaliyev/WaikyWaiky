//
//  CheckInView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI
import EventKit

struct CheckInView: View {
    @State private var healthManager = HealthManager()
    @State private var openAIManager = OpenAIManager()
    @State private var moodRating: Double = 3.0
    @State private var sleepQuality: Double = 3.0
    @State private var skipMood = false
    @State private var skipSleep = false
    @State private var heartRate: Double? = nil
    @State private var sleepHours: Double? = nil
    @State private var aiNudge: String? = nil
    @State private var isLoadingNudge = false
    @State private var todayEvents: [EKEvent] = []
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Check In")
                    .font(.largeTitle)
                    .bold()

                VStack(spacing: 24) {
                    // Mood Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("How are you feeling?")
                                .font(.headline)
                            Spacer()
                            Button(skipMood ? "Add" : "Skip") {
                                skipMood.toggle()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        if !skipMood {
                            VStack(spacing: 8) {
                                HStack {
                                    Text(moodLabel)
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(moodColor)
                                    Spacer()
                                }
                                
                                Slider(value: $moodRating, in: 1...5, step: 0.5)
                                    .tint(moodColor)
                                
                                HStack {
                                    Text("Struggling")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("Thriving")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            Text("Skipped")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                        }
                    }

                    // Sleep Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("How did you sleep?")
                                .font(.headline)
                            Spacer()
                            Button(skipSleep ? "Add" : "Skip") {
                                skipSleep.toggle()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        if !skipSleep {
                            VStack(spacing: 8) {
                                HStack {
                                    Text(sleepLabel)
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(sleepColor)
                                    Spacer()
                                }
                                
                                Slider(value: $sleepQuality, in: 1...5, step: 0.5)
                                    .tint(sleepColor)
                                
                                HStack {
                                    Text("Restless")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("Refreshed")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            Text("Skipped")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                        }
                    }
                }

                Button("Submit Check-In") {
                    print("Mood: \(skipMood ? "skipped" : String(format: "%.1f", moodRating)), Sleep: \(skipSleep ? "skipped" : String(format: "%.1f", sleepQuality))")
                    isLoadingNudge = true
                    aiNudge = nil
                    
                    let isBusyDay = CalendarManager.shared.isBusyDay(events: todayEvents)
                    
                    openAIManager.generateNudge(
                        mood: skipMood ? 0 : Int(moodRating.rounded()),
                        sleepQuality: skipSleep ? 0 : Int(sleepQuality.rounded()),
                        heartRate: heartRate,
                        sleepHours: sleepHours,
                        isBusyDay: isBusyDay
                    ) { nudge in
                        isLoadingNudge = false
                        if let nudge = nudge {
                            aiNudge = nudge
                            saveNudge(nudge)
                        } else {
                            aiNudge = "Unable to generate a personalized nudge right now. Try again!"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoadingNudge || (skipMood && skipSleep))
                
                // AI Response Display
                if isLoadingNudge {
                    ProgressView()
                        .padding()
                } else if let nudge = aiNudge {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Personalized Nudge")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(nudge)
                            .font(.body)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 8)
                }
                
                // Debug button - remove after testing
                Button("Seed Test Data") {
                    healthManager.seedSimulatedData { success in
                        print("Seeded simulated data: \(success)")
                        if success {
                            // Small delay to ensure HealthKit has indexed the new data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Refresh the data
                                healthManager.fetchLatestHeartRate { hr in
                                    DispatchQueue.main.async {
                                        heartRate = hr
                                        print("Heart rate refreshed: \(hr ?? 0)")
                                    }
                                }
                                healthManager.fetchLastNightSleepHours { sleep in
                                    DispatchQueue.main.async {
                                        sleepHours = sleep
                                        print("Sleep hours refreshed: \(sleep ?? 0)")
                                    }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.bordered)
                .font(.caption)
                
                if let hr = heartRate, let sleep = sleepHours {
                    Text("HR: \(Int(hr)) bpm · Sleep: \(String(format: "%.1f", sleep))h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let hr = heartRate {
                    Text("HR: \(Int(hr)) bpm · Sleep: no data")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let sleep = sleepHours {
                    Text("HR: no data · Sleep: \(String(format: "%.1f", sleep))h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Fetching health data...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .onAppear {
                healthManager.requestAuthorization { success in
                    print("Authorization success: \(success)")
                    if success {
                        healthManager.fetchLatestHeartRate { hr in
                            DispatchQueue.main.async {
                                heartRate = hr
                                print("Heart rate fetched: \(hr ?? 0)")
                            }
                        }
                        healthManager.fetchLastNightSleepHours { sleep in
                            DispatchQueue.main.async {
                                sleepHours = sleep
                                print("Sleep hours refreshed: \(sleep ?? 0)")
                            }
                        }
                    }
                }
                
                // Load calendar events for context
                Task {
                    let granted = await CalendarManager.shared.requestCalendarAccess()
                    if granted {
                        todayEvents = await CalendarManager.shared.fetchTodayEvents()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Computed properties for mood labels and colors
    private var moodLabel: String {
        switch moodRating {
        case 1.0..<2.0: return "Struggling"
        case 2.0..<3.0: return "Challenging"
        case 3.0..<4.0: return "Okay"
        case 4.0..<5.0: return "Good"
        default: return "Thriving"
        }
    }
    
    private var moodColor: Color {
        switch moodRating {
        case 1.0..<2.0: return .red
        case 2.0..<3.0: return .orange
        case 3.0..<4.0: return .yellow
        case 4.0..<5.0: return .green
        default: return .blue
        }
    }
    
    private var sleepLabel: String {
        switch sleepQuality {
        case 1.0..<2.0: return "Restless"
        case 2.0..<3.0: return "Interrupted"
        case 3.0..<4.0: return "Fair"
        case 4.0..<5.0: return "Good"
        default: return "Refreshed"
        }
    }
    
    private var sleepColor: Color {
        switch sleepQuality {
        case 1.0..<2.0: return .red
        case 2.0..<3.0: return .orange
        case 3.0..<4.0: return .yellow
        case 4.0..<5.0: return .green
        default: return .purple
        }
    }
    
    private func saveNudge(_ nudge: String) {
        UserDefaults.standard.set(nudge, forKey: "lastNudge")
        UserDefaults.standard.set(Date(), forKey: "lastNudgeDate")
        
        // Save to check-in history (use 0 for skipped values, rounded for storage)
        CheckInHistoryManager.shared.saveCheckIn(
            mood: skipMood ? 0 : Int(moodRating.rounded()),
            sleepQuality: skipSleep ? 0 : Int(sleepQuality.rounded()),
            nudge: nudge
        )
        
        print("✅ Saved nudge to UserDefaults and history")
    }
}

#Preview {
    CheckInView()
}
