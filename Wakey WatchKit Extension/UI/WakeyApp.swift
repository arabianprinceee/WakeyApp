//
//  WakeyApp.swift
//  Wakey WatchKit Extension
//
//  Created by Анас Бен Мустафа on 1/12/23.
//

import SwiftUI

@main
struct WakeyApp: App {

    @State private var shouldStartMainFlow = false
    @State private var shouldShowLoadingView = false

    private let permissionManager = HealthKitPermissionManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if shouldShowLoadingView {
                    AppLoadingView()
                } else {
                    if shouldStartMainFlow {
                        AlarmSelectionView()
                    } else {
                        AccessNotGrantedView()
                    }
                }
            }
            .onAppear {
                permissionManager.checkReadPermissions(type: .heart) { accessGranted, error in
                    guard error == nil else { return }
                    shouldShowLoadingView = false
                    shouldStartMainFlow = accessGranted
                }
            }
        }
    }
}
