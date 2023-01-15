//
//  WakeyApp
//
//  Copyright (c) Анас Бен Мустафа.
//

import Foundation
import HealthKit
import SwiftLogger

protocol HealthKitDataFetcherDelegate: AnyObject {

    func healthKitDataFetcherDidFetchNewHeartbeatValue(_: HealthKitDataFetcher, value: HeartbeatValue)

}

final class HealthKitDataFetcher {

    // MARK: - Internal Properties

    weak var delegate: HealthKitDataFetcherDelegate?

    // MARK: - Private Properties

    private let logger = Logger.default
    private let healthStore = HKHealthStore()

    // MARK: - Internal Methods

    func start() {
        guard
            let sampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        else { return }

        let heartRateQuery = HKObserverQuery(
            sampleType: sampleType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            // This is fired every time new samples are retrieved
            // This also seems to turn on active sensing to get heart rates every ~5 seconds
            guard error == nil else { return }

            // Get the actual query
            self?.startHeartRateQuery(quantityTypeIdentifier: .heartRate)

            // Unclear if I actually need this, but it doesn't change anything
            completionHandler()
        }

        // Execute the actual query
        healthStore.execute(heartRateQuery)
    }

    // MARK: - Private Methods

    private func startHeartRateQuery(quantityTypeIdentifier _: HKQuantityTypeIdentifier) {
        // Set the predicate to get only samples from the last hour
        // Could be last minute and should be just fine
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date().addingTimeInterval(-3600),
                end: Date(),
                options: []
            )

        // Sort most recent
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            predicate: predicate,
            limit: Int(1), // To get only one
            sortDescriptors: [sortDescriptor]
        ) { _, results, _ in
            // Fired when query completes
            guard
                let samples = results as? [HKQuantitySample]
            else { return }
            // Should only be one sample
            for s in samples {
                let heartbeatValue = s.quantity.doubleValue(for: HealthType.heart.unit)
                // Log heart rate to my internal structure for processing
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.logger.log(.information, "Got new heartbeat value: \(heartbeatValue)")
                    self.delegate?.healthKitDataFetcherDidFetchNewHeartbeatValue(self, value: heartbeatValue)
                }
            }
        }

        healthStore.execute(query)
    }

}
