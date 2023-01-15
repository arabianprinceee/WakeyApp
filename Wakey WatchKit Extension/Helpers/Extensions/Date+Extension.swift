//
//  Date+Extension.swift
//  Wakey WatchKit Extension
//
//  Created by Анас Бен Мустафа on 1/15/23.
//

import Foundation

extension Date {

    func nextTimeMatchingComponents(
        inDirection direction: Calendar.SearchDirection = .forward,
        using calendar: Calendar = .current,
        components: DateComponents
    ) -> Date {
        return calendar.nextDate(
            after: self,
            matching: components,
            matchingPolicy: .nextTime,
            direction: direction
        )!
    }

    func getHourInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("HH")
        return Int(df.string(from: self))!
    }

    func getMinuteInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("mm")
        return Int(df.string(from: self))!
    }

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

}
