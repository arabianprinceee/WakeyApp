// Copyright (c) 2022 Sleepy.

import Foundation
import WatchKit
import SwiftLogger

final class SmartAlarm: NSObject {

    private let logger = Logger.default
    private let healthManager = HealthManager()
    private var runtimeSession: WKExtendedRuntimeSession?

    private var seconds: Int = 1500 // Equals to 25 mins
    private var timer: Timer?

    override init() {
        super.init()

        healthManager.delegate = self
    }

    /// Returns `true` if activated successfully
    func activate(forTime alarmTime: Date) {
        let scheduledTime = Calendar.current.date(byAdding: .minute, value: -29, to: alarmTime)!
        if runtimeSession == nil || runtimeSession?.state == .invalid {
            runtimeSession = WKExtendedRuntimeSession()
            runtimeSession?.delegate = self
        }
        runtimeSession?.start(at: scheduledTime)
        WakeySettings.isAlarmEnabled = true
        logger.log(.information, "setupSession at \(scheduledTime)")
    }

    func deactivate() {
        runtimeSession?.invalidate()
        runtimeSession = nil
        WakeySettings.isAlarmEnabled = false
        logger.log(.information, "deactivating stssion")
    }

    // MARK: - Private Methods

    private func triggerAlarm() {
        WakeySettings.isAlarmEnabled = false
        runtimeSession?.notifyUser(hapticType: .notification) { _ in 3 }
        logger.log(.information, "triggers alarm")
    }

    private func startTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(self.updateTimer),
                userInfo: nil,
                repeats: true
            )
            self.timer?.fire()
        }
    }

    @objc
    private func updateTimer() {
        guard
            seconds > 0,
            let timer = timer,
            timer.isValid
        else {
            timer?.invalidate()
            triggerAlarm()
            return
        }
        seconds -= 1
        print("Seconds left before trigger: \(seconds)")
    }

}

// MARK: - Protocol HealthManagerDelegate

extension SmartAlarm: HealthManagerDelegate {

    func healthManagerDidDetectLightPhase(_: HealthManager) {
        triggerAlarm()
        logger.log(.information, "healthManagerDidDetectLightPhase")
    }

}

// MARK: - Protocol WKExtendedRuntimeSessionDelegate

extension SmartAlarm: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Track when your session starts.
        healthManager.start()
        startTimer()
        logger.log(.information, "extendedRuntimeSessionDidStart")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        WakeySettings.isAlarmEnabled = false
        timer?.invalidate()
        logger.log(.information, "extendedRuntimeSessionWillExpire")
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        logger.log(.information, "extendedRuntimeSession didInvalidateWith error reason: \(reason)")
        WakeySettings.isAlarmEnabled = false
        timer?.invalidate()
    }

}

// MARK: - Protocol WKExtensionDelegate

extension SmartAlarm: WKExtensionDelegate {

    func handle(_ session: WKExtendedRuntimeSession) {
        session.delegate = self
        runtimeSession = session
        logger.log(.information, "handle WKExtendedRuntimeSession started")
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
