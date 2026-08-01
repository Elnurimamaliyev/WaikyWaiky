//
//  ContentView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var healthManager = HealthManager()
    @State private var openAIManager = OpenAIManager()
    @State private var moodRating: Int = 3
    @State private var sleepQuality: Int = 3
    @State private var heartRate: Double? = nil
    @State private var sleepHours: Double? = nil
    @State private var aiNudge: String? = nil
    @State private var isLoadingNudge = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Good morning 👋")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading) {
                Text("How are you feeling?")
                    .font(.headline)
                Picker("Mood", selection: $moodRating) {
                    ForEach(1...5, id: \.self) { value in
                        Text("\(value)")
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading) {
                Text("How did you sleep?")
                    .font(.headline)
                Picker("Sleep", selection: $sleepQuality) {
                    ForEach(1...5, id: \.self) { value in
                        Text("\(value)")
                    }
                }
                .pickerStyle(.segmented)
            }

            Button("Check In") {
                print("Mood: \(moodRating), Sleep: \(sleepQuality)")
                isLoadingNudge = true
                aiNudge = nil
                
                openAIManager.generateNudge(
                    mood: moodRating,
                    sleepQuality: sleepQuality,
                    heartRate: heartRate,
                    sleepHours: sleepHours
                ) { nudge in
                    isLoadingNudge = false
                    aiNudge = nudge ?? "Unable to generate a personalized nudge right now. Try again!"
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoadingNudge)
            
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
                            print("Sleep hours fetched: \(sleep ?? 0)")
                        }
                    }
                }
            }
        }
    }
}
