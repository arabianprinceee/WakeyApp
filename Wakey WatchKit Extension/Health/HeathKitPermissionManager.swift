//
//  WakeyApp
//
//  Copyright (c) Анас Бен Мустафа.
//

import Foundation
import HealthKit

final class HealthKitPermissionManager {

    // MARK: - Private Properties

    private let healthStore = HKHealthStore()

    // MARK: - Internal Methods

    func checkReadPermissions(
        type: HealthType,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        self.readDataLast(type: type, completionHandler: { _, samples, error in
            if error != nil || (samples ?? []).isEmpty {
                self.makeHealthKitRequest()
                self.checkReadPermissions(type: type, completionHandler: completionHandler)
            } else {
                completionHandler(true, error)
            }
        })
    }

    // MARK: - Private Methods

    private func readDataLast(
        type: HealthType,
        completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void
    ) {
        let sortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])
        let query = HKSampleQuery(
            sampleType: type.sample,
            predicate: predicate,
            limit: 1,
            sortDescriptors: sortDescriptor,
            resultsHandler: completionHandler
        )
        self.healthStore.execute(query)
    }

    private func makeHealthKitRequest() {
        let requiredHealthKitTypes: Set = [HealthType.heart.sample]
        self.healthStore.requestAuthorization(toShare: [], read: requiredHealthKitTypes) { _, _ in }
    }

}
