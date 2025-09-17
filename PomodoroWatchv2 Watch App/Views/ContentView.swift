//
//  ContentView.swift
//  PomodoroWatchv2 Watch App
//
//  Created by Romain  Lagrange on 17/09/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pomodoroTimer: PomodoroTimer

    var body: some View {
        VStack(spacing: 20) {
            // Session Type Display
            Text(pomodoroTimer.currentSessionType.displayName)
                .font(.headline)
                .foregroundStyle(.secondary)

            // Main Timer Display
            VStack(spacing: 8) {
                Text(pomodoroTimer.formattedTime)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))

                Text(pomodoroTimer.currentState.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Basic Controls
            HStack(spacing: 12) {
                // Main Start/Pause button
                Button(pomodoroTimer.isRunning ? "Pause" : "Start") {
                    if pomodoroTimer.isRunning {
                        pomodoroTimer.pauseTimer()
                    } else {
                        pomodoroTimer.startTimer()
                    }
                }
                .buttonStyle(.borderedProminent)

                // Dynamic Reset/Skip button
                Button(pomodoroTimer.isRunning ? "Reset" : "Skip") {
                    if pomodoroTimer.isRunning {
                        pomodoroTimer.resetTimer()
                    } else {
                        pomodoroTimer.skipToNextSession()
                    }
                }
                .buttonStyle(.bordered)
            }

            // Session Counter
            Text("Sessions: \(pomodoroTimer.sessionsCompleted)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroTimer())
}
