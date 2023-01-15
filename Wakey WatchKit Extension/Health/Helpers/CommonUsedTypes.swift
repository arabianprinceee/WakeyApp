//
//  WakeyApp
//
//  Copyright (c) Анас Бен Мустафа.
//

import Foundation
import HealthKit

typealias HeartbeatValue = Double

enum HealthType {
    
    case heart

    var sample: HKSampleType {
        switch self {
        case .heart:
            return HKSampleType.quantityType(forIdentifier: .heartRate)!
        }
    }

    var unit: HKUnit {
        switch self {
        case .heart:
            return HKUnit(from: "count/min")
        }
    }

}
