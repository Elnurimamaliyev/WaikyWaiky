//
//  HealthManager.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [sleepType, heartRateType]
        let typesToWrite: Set<HKSampleType> = [sleepType, heartRateType]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            completion(success)
        }
    }
    
    func seedSimulatedData(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var overallSuccess = true
        
        // Add simulated sleep data (7.5 hours from 11 PM to 6:30 AM)
        group.enter()
        addSimulatedSleep { success in
            if !success { overallSuccess = false }
            group.leave()
        }
        
        // Add simulated heart rate data
        group.enter()
        addSimulatedHeartRate { success in
            if !success { overallSuccess = false }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(overallSuccess)
        }
    }
    
    private func addSimulatedSleep(completion: @escaping (Bool) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Create sleep from 11 PM yesterday to 6:30 AM today (7.5 hours)
        let endDate = calendar.startOfDay(for: now).addingTimeInterval(6.5 * 3600) // 6:30 AM today
        let startDate = endDate.addingTimeInterval(-7.5 * 3600) // 11 PM yesterday
        
        let sleepSample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: startDate,
            end: endDate
        )
        
        healthStore.save(sleepSample) { success, error in
            if success {
                print("✅ Simulated sleep data added: 7.5 hours")
            } else {
                print("❌ Failed to add sleep data: \(error?.localizedDescription ?? "unknown")")
            }
            completion(success)
        }
    }
    
    private func addSimulatedHeartRate(completion: @escaping (Bool) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(false)
            return
        }
        
        let heartRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: 72.0)
        let now = Date()
        
        let heartRateSample = HKQuantitySample(
            type: heartRateType,
            quantity: heartRateQuantity,
            start: now,
            end: now
        )
        
        healthStore.save(heartRateSample) { success, error in
            if success {
                print("✅ Simulated heart rate added: 72 bpm")
            } else {
                print("❌ Failed to add heart rate: \(error?.localizedDescription ?? "unknown")")
            }
            completion(success)
        }
    }
    
    func fetchLatestHeartRate(completion: @escaping (Double?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            completion(heartRate)
        }
        
        healthStore.execute(query)
    }
    
    func fetchLastNightSleepHours(completion: @escaping (Double?) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        // Sort by end date descending to get the most recent sleep session
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKCategorySample else {
                completion(nil)
                return
            }
            
            // Only count asleep values
            if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
               sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
               sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
               sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                
                let sleepSeconds = sample.endDate.timeIntervalSince(sample.startDate)
                let sleepHours = sleepSeconds / 3600.0
                completion(sleepHours > 0 ? sleepHours : nil)
            } else {
                completion(nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    func saveSleepHours(hours: Double, completion: @escaping (Bool) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Delete sleep data from last 24 hours first to prevent accumulation
        let twentyFourHoursAgo = calendar.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: twentyFourHoursAgo, end: now, options: .strictStartDate)
        
        healthStore.deleteObjects(of: sleepType, predicate: predicate) { success, deletedCount, error in
            if success {
                print("✅ Deleted \(deletedCount) old sleep samples from last 24 hours")
            }
            
            // Now create new sleep sample
            let endDate = calendar.startOfDay(for: now).addingTimeInterval(8 * 3600) // 8 AM today
            let startDate = endDate.addingTimeInterval(-hours * 3600)
            
            let sleepSample = HKCategorySample(
                type: sleepType,
                value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                start: startDate,
                end: endDate
            )
            
            self.healthStore.save(sleepSample) { success, error in
                if success {
                    print("✅ Custom sleep data saved: \(hours) hours")
                } else {
                    print("❌ Failed to save custom sleep data: \(error?.localizedDescription ?? "unknown")")
                }
                completion(success)
            }
        }
    }
}
