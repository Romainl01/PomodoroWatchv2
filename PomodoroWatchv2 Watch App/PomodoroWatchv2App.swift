//
//  PomodoroWatchv2App.swift
//  PomodoroWatchv2 Watch App
//
//  Created by Romain  Lagrange on 17/09/2025.
//

import SwiftUI

@main
struct PomodoroWatchv2_Watch_AppApp: App {
    @StateObject private var pomodoroTimer = PomodoroTimer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pomodoroTimer)
                .task {
                    // Request notification permission when app launches
                    await NotificationManager.shared.requestPermission()
                }
        }
    }
}
