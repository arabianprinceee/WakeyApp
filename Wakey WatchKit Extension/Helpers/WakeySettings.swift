import Foundation

struct WakeySettings {

    @UserDefault("isAlarmEnabled", defaultValue: false)
    static var isAlarmEnabled: Bool

    @UserDefault("scheduledAlarmHour", defaultValue: -1)
    static var scheduledAlarmHour: Int

    @UserDefault("scheduledAlarmMinute", defaultValue: -1)
    static var scheduledAlarmMinute: Int

}
