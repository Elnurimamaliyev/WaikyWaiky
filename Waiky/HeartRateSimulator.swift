//
//  HeartRateSimulator.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import Foundation
import HealthKit

class HeartRateSimulator: ObservableObject {
    @Published var currentHeartRate: Double = 72.0
    @Published var isSimulating: Bool = false
    
    private var timer: Timer?
    private let healthStore = HKHealthStore()
    
    static let shared = HeartRateSimulator()
    
    private init() {}
    
    // Start simulating realistic resting heart rate (60-80 BPM with slight variations)
    func startSimulation() {
        guard !isSimulating else { return }
        isSimulating = true
        
        print("🫀 Heart rate simulator started")
        
        // Update every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.generateAndSaveHeartRate()
        }
        
        // Generate initial value
        generateAndSaveHeartRate()
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
        print("🫀 Heart rate simulator stopped")
    }
    
    private func generateAndSaveHeartRate() {
        // Simulate realistic resting heart rate with small variations
        let baseRate = 70.0
        let variation = Double.random(in: -8...10) // 62-80 BPM range
        currentHeartRate = baseRate + variation
        
        // Save to HealthKit
        saveHeartRateToHealthKit(bpm: currentHeartRate)
    }
    
    private func saveHeartRateToHealthKit(bpm: Double) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let heartRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: bpm)
        let now = Date()
        
        let heartRateSample = HKQuantitySample(
            type: heartRateType,
            quantity: heartRateQuantity,
            start: now,
            end: now
        )
        
        healthStore.save(heartRateSample) { success, error in
            if success {
                print("🫀 Simulated heart rate saved: \(Int(bpm)) BPM at \(now.formatted(date: .omitted, time: .standard))")
            } else {
                print("❌ Failed to save simulated heart rate: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
}
