//
//  ContentView.swift
//  Wakey WatchKit Extension
//
//  Created by Анас Бен Мустафа on 1/12/23.
//

import SwiftUI

struct AlarmSelectionView: View {

    @State private var hasActiveAlarm = false
    @State private var selectedHour = Date().getHourInt()
    @State private var selectedMinute = Date().getMinuteInt()

    private let smartAlarm = SmartAlarm()

    private let hours = [Int](0...23)
    private let minutes = [Int](0...59)

    var body: some View {
        if hasActiveAlarm {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "bed.double.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 36))

                    Text(
                        String(
                            format: "The smart alarm clock is set for %@:%@",
                            makeConvenientTimeRepresentation(from: WakeySettings.scheduledAlarmHour),
                            makeConvenientTimeRepresentation(from: WakeySettings.scheduledAlarmMinute)
                        )
                    )
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)

                    Button {
                        deactivateAlarm()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .onAppear {
                setup()
            }
        } else {
            VStack {
                HStack {
                    Picker("Hour", selection: $selectedHour) {
                        ForEach(hours, id: \.self) {
                            Text(makeConvenientTimeRepresentation(from: $0))
                        }
                    }

                    Picker("Minute", selection: $selectedMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(makeConvenientTimeRepresentation(from: $0))
                        }
                    }
                }
                .frame(height: 80)

                ScrollView {
                    Button {
                        activateAlarm()
                    } label: {
                        Text("Setup")
                    }
                    .padding(.top, 8)

                    Text("Smart alarm requires at least 30 minutes interval to be activated.")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .onAppear {
                setup()
            }
        }
    }

    // MARK: - Private Methods

    private func setup() {
        hasActiveAlarm = WakeySettings.isAlarmEnabled
    }

    private func activateAlarm() {
        let alarmScheduledTime = Date().nextTimeMatchingComponents(
            components: DateComponents(
                hour: self.selectedHour,
                minute: self.selectedMinute
            )
        )
        if alarmScheduledTime.minutes(from: Date()) >= 30 {
            smartAlarm.activate(forTime: alarmScheduledTime)
            hasActiveAlarm = true
            saveAdditionalAlarmInformation()
        }
    }

    private func deactivateAlarm() {
        smartAlarm.deactivate()
        hasActiveAlarm = false
    }

    private func saveAdditionalAlarmInformation() {
        WakeySettings.scheduledAlarmHour = selectedHour
        WakeySettings.scheduledAlarmMinute = selectedMinute
    }

    private func makeConvenientTimeRepresentation(from integer: Int) -> String {
        let minutesStr = integer > 9 ? String(integer) : "0" + String(integer)
        return minutesStr
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmSelectionView()
    }
}
