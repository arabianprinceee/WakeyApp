//
//  WakeyApp
//
//  Copyright (c) Анас Бен Мустафа.
//

import Foundation
import HealthKit

protocol HealthManagerDelegate: AnyObject {
    func healthManagerDidDetectLightPhase(_: HealthManager)
}

final class HealthManager {

    // MARK: - Internal Properties

    weak var delegate: HealthManagerDelegate?

    // MARK: - Private Properties

    private let healthKitDataFetcher = HealthKitDataFetcher()
    private let lightPhaseDectectionProvider = LightPhaseDectectionProvider()

    // MARK: - Init

    init() {
        lightPhaseDectectionProvider.delegate = self
        healthKitDataFetcher.delegate = self
    }

    // MARK: - Internal Methods

    func start() {
        healthKitDataFetcher.start()
    }

}

// MARK: - Protocol LightPhaseDectectionProviderDelegate

extension HealthManager: LightPhaseDectectionProviderDelegate {

    func lightPhaseDectectionProviderDidDetectLightPhase(_: LightPhaseDectectionProvider) {
        delegate?.healthManagerDidDetectLightPhase(self)
    }

}

// MARK: - Protocol

extension HealthManager: HealthKitDataFetcherDelegate {

    func healthKitDataFetcherDidFetchNewHeartbeatValue(
        _: HealthKitDataFetcher,
        value: HeartbeatValue
    ) {
        lightPhaseDectectionProvider.registerNewHeartbeat(value)
    }

}
