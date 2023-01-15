//
//  WakeyApp
//
//  Copyright (c) Анас Бен Мустафа.
//

import Foundation

protocol LightPhaseDectectionProviderDelegate: AnyObject {
    func lightPhaseDectectionProviderDidDetectLightPhase(_: LightPhaseDectectionProvider)
}

final class LightPhaseDectectionProvider {

    // MARK: - Private Types

    private enum Constant {
        static let confirmativeLightPhaseFlagValue: Double = 1.05
        static let potentialLightPhaseFlagValue: Double = 1.08
        static let unconditionalLightPhaseDetectionValue: Double = 1.12
    }

    private enum LightPhaseDetectionStrategy {
        case withConfirmation
        case withoutConfirmation
    }

    // MARK: - Internal Properties

    weak var delegate: LightPhaseDectectionProviderDelegate?

    // MARK: - Private Properties

    private var heartRates = [HeartbeatValue]()
    private var potentialLightPhaseDetectionFlag: Bool = false

    // MARK: - Internal methods

    func registerNewHeartbeat(_ value: HeartbeatValue) {
        heartRates.append(value)
        tryDetectLightPhase()
    }

    // MARK: - Private methods

    private func tryDetectLightPhase() {
        guard
            heartRates.count > 1,
            let last = heartRates.last,
            let preLast = heartRates.dropLast().last
        else { return }
        let differencePercentage = last / preLast
        if differencePercentage >= Constant.unconditionalLightPhaseDetectionValue {
            detectLightPhaseWithStrategy(.withoutConfirmation)
        } else {
            detectLightPhaseWithStrategy(.withConfirmation)
        }
    }

    private func detectLightPhaseWithStrategy(_ strategy: LightPhaseDetectionStrategy) {
        switch strategy {
        case .withConfirmation:
            if potentialLightPhaseDetectionFlag, isLightPhaseDetectionConfirmed() {
                delegate?.lightPhaseDectectionProviderDidDetectLightPhase(self)
            } else {
                detectPotentialLightPhase()
            }
        case .withoutConfirmation:
            delegate?.lightPhaseDectectionProviderDidDetectLightPhase(self)
        }
    }

    private func detectPotentialLightPhase() {
        guard
            let last = heartRates.last,
            let preLast = heartRates.dropLast().last,
            last / preLast >= Constant.potentialLightPhaseFlagValue
        else {
            return
        }
        potentialLightPhaseDetectionFlag = true
    }

    private func isLightPhaseDetectionConfirmed() -> Bool {
        guard
            heartRates.count > 2,
            let last = heartRates.last,
            let prePreLast = heartRates.dropLast().dropLast().last,
            last / prePreLast >= Constant.confirmativeLightPhaseFlagValue
        else {
            potentialLightPhaseDetectionFlag = false
            return false
        }
        return true
    }

}
