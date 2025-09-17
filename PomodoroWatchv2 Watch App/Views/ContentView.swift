//
//  ContentView.swift
//  PomodoroWatchv2 Watch App
//
//  Created by Romain  Lagrange on 17/09/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pomodoroTimer: PomodoroTimer

    private var progressColor: Color {
        switch pomodoroTimer.currentSessionType {
        case .work:
            return .orange
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Session Type Display
            Text(pomodoroTimer.currentSessionType.displayName)
                .font(.caption)
                .foregroundStyle(progressColor)

            // Main Timer Display with Progress Ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.3)
                    .foregroundStyle(.gray)

                // Progress circle
                Circle()
                    .trim(from: 0.0, to: CGFloat(pomodoroTimer.progress))
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(progressColor)
                    .rotationEffect(Angle(degrees: 270))

                // Timer text in center
                VStack(spacing: 2) {
                    Text(pomodoroTimer.formattedTime)
                        .font(.system(size: 26, weight: .bold, design: .monospaced))

                    Text(pomodoroTimer.currentState.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            // Controls
            HStack(spacing: 10) {
                Button(pomodoroTimer.isRunning ? "Pause" : "Start") {
                    if pomodoroTimer.isRunning {
                        pomodoroTimer.pauseTimer()
                    } else {
                        pomodoroTimer.startTimer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                Button(pomodoroTimer.isRunning ? "Reset" : "Skip") {
                    if pomodoroTimer.isRunning {
                        pomodoroTimer.resetTimer()
                    } else {
                        pomodoroTimer.skipToNextSession()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            // Session Counter
            Text("Session \(pomodoroTimer.sessionsCompleted + 1)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroTimer())
}
