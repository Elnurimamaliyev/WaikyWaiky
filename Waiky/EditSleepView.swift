//
//  EditSleepView.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

struct EditSleepView: View {
    @State private var sleepHours: Double
    @State private var healthManager = HealthManager()
    @Environment(\.dismiss) var dismiss
    
    var currentSleep: Double
    var onSave: (Double) -> Void
    
    init(currentSleep: Double, onSave: @escaping (Double) -> Void) {
        self.currentSleep = currentSleep
        self.onSave = onSave
        _sleepHours = State(initialValue: currentSleep)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Edit Sleep Hours")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 12) {
                    Text("\(String(format: "%.1f", sleepHours)) hours")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                    
                    Slider(value: $sleepHours, in: 0...12, step: 0.5)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("0h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("12h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding()
                
                Text("Adjust the slider to set your sleep hours manually")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Save Sleep Data") {
                        saveSleepData()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Use HealthKit Data") {
                        loadFromHealthKit()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
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
    
    private func saveSleepData() {
        // Save custom sleep hours to HealthKit
        healthManager.saveSleepHours(hours: sleepHours) { success in
            if success {
                print("✅ Sleep data saved: \(sleepHours) hours")
                onSave(sleepHours)
                dismiss()
            } else {
                print("❌ Failed to save sleep data")
            }
        }
    }
    
    private func loadFromHealthKit() {
        healthManager.fetchLastNightSleepHours { sleep in
            DispatchQueue.main.async {
                if let sleep = sleep {
                    sleepHours = sleep
                    onSave(sleep)
                    print("✅ Loaded sleep from HealthKit: \(sleep) hours")
                }
            }
        }
    }
}

#Preview {
    EditSleepView(currentSleep: 7.5) { _ in }
}
