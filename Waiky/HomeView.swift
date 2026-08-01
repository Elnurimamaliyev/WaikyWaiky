//
//  HomeView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var healthManager = HealthManager()
    @State private var heartRate: Double? = nil
    @State private var sleepHours: Double? = nil
    @State private var showCheckIn = false
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
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
                        Text("Today's Health")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
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
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // TODO: Navigate to focus timer
                            print("Focus Session tapped")
                        }) {
                            HStack {
                                Image(systemName: "timer")
                                Text("Focus Session")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Waiky")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadHealthData()
                notificationManager.requestPermission()
            }
            .sheet(isPresented: $showCheckIn) {
                CheckInView()
            }
            .onChange(of: notificationManager.shouldShowCheckIn) { _, newValue in
                if newValue {
                    showCheckIn = true
                    notificationManager.shouldShowCheckIn = false
                }
            }
            .refreshable {
                loadHealthData()
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
}

#Preview {
    HomeView()
}
