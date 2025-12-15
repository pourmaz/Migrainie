import Foundation
import HealthKit
import Combine


final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    
    private init() {}
    
    // Types we want to read
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) {
            types.insert(steps)
        }
        if let dist = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            types.insert(dist)
        }
        if let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(hr)
        }
        return types
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false); return
        }
        store.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                completion(success)
            }
            if let error { print("HealthKit auth error:", error.localizedDescription) }
        }
    }
    
    // MARK: - Fetch context for a day (start-of-day to end-of-day)
    func fetchDailyContext(for day: Date, completion: @escaping (DailyContext) -> Void) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        
        let group = DispatchGroup()
        var ctx = DailyContext(day: start)
        
        group.enter()
        fetchSleepHours(from: start, to: end) { value in
            ctx.sleepHours = value
            group.leave()
        }
        
        group.enter()
        fetchCumulative(.stepCount, unit: .count(), from: start, to: end) { value in
            ctx.steps = value
            group.leave()
        }
        
        group.enter()
        fetchCumulative(.distanceWalkingRunning, unit: .meter(), from: start, to: end) { meters in
            ctx.distanceKm = meters.map { $0 / 1000.0 }
            group.leave()
        }
        
        group.enter()
        fetchCumulative(.activeEnergyBurned, unit: .kilocalorie(), from: start, to: end) { kcal in
            ctx.activeEnergyKcal = kcal
            group.leave()
        }
        
        group.enter()
        fetchAverageHeartRate(from: start, to: end) { bpm in
            ctx.avgHeartRateBpm = bpm
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(ctx)
        }
    }
    
    // MARK: - Sleep: sum of asleep segments
    private func fetchSleepHours(from start: Date, to end: Date, completion: @escaping (Double?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil); return
        }
        
        let pred = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictEndDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let q = HKSampleQuery(sampleType: sleepType, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) {
            _, samples, error in
            if let error { print("Sleep query error:", error.localizedDescription); completion(nil); return }
            guard let samples = samples as? [HKCategorySample] else { completion(nil); return }
            
            let asleep = samples.filter {
                $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
            }
            let seconds = asleep.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            completion(seconds > 0 ? seconds / 3600.0 : nil)
        }
        store.execute(q)
    }
    
    // MARK: - Cumulative (steps/distance/energy)
    private func fetchCumulative(_ id: HKQuantityTypeIdentifier,
                                 unit: HKUnit,
                                 from start: Date,
                                 to end: Date,
                                 completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { completion(nil); return }
        let pred = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) {
            _, stats, error in
            if let error { print("Cumulative query error:", error.localizedDescription); completion(nil); return }
            completion(stats?.sumQuantity()?.doubleValue(for: unit))
        }
        store.execute(q)
    }
    
    // MARK: - HR average for the day
    private func fetchAverageHeartRate(from start: Date, to end: Date, completion: @escaping (Double?) -> Void) {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else { completion(nil); return }
        let pred = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let q = HKStatisticsQuery(quantityType: hrType, quantitySamplePredicate: pred, options: .discreteAverage) {
            _, stats, error in
            if let error { print("HR avg query error:", error.localizedDescription); completion(nil); return }
            let unit = HKUnit.count().unitDivided(by: .minute())
            let bpm = stats?.averageQuantity()?.doubleValue(for: unit)
            completion(bpm)
        }
        store.execute(q)
    }
}
//
//  HealthKitManager.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 15/12/25.
//

