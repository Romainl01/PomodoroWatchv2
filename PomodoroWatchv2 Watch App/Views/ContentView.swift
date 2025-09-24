//
//  ContentView.swift
//  PomodoroWatchv2 Watch App
//
//  Created by Romain  Lagrange on 17/09/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pomodoroTimer: PomodoroTimer
    @State private var longPressProgress: Double = 0.0
    @State private var isLongPressing = false
    @State private var touchStartTime: Date?

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
                    .animation(.easeInOut(duration: 1.0), value: pomodoroTimer.progress)
                    .animation(.easeInOut(duration: 0.5), value: progressColor)

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

             // Session Type Display
            Text(pomodoroTimer.currentSessionType.displayName)
                .font(.caption)
                .foregroundStyle(progressColor)
                .animation(.easeInOut(duration: 0.5), value: progressColor)
                .animation(.easeInOut(duration: 0.3), value: pomodoroTimer.currentSessionType)

            // Controls
            HStack(spacing: 10) {
                Button(pomodoroTimer.isRunning ? "Pause" : "Start") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if pomodoroTimer.isRunning {
                            pomodoroTimer.pauseTimer()
                        } else {
                            pomodoroTimer.startTimer()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .animation(.easeInOut(duration: 0.3), value: pomodoroTimer.isRunning)

                // Reset/Skip Button with Long Press
                ZStack {
                    // Background progress indicator for long press
                    if isLongPressing {
                        Circle()
                            .trim(from: 0.0, to: CGFloat(longPressProgress))
                            .stroke(.red, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: longPressProgress)
                    }

                    Button(pomodoroTimer.isRunning ? "Reset" : "Skip") {
                        // Button action - will be triggered by our custom gesture
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .scaleEffect(isLongPressing ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isLongPressing)
                    .animation(.easeInOut(duration: 0.3), value: pomodoroTimer.isRunning)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isLongPressing {
                                    isLongPressing = true
                                    touchStartTime = Date()
                                    withAnimation(.linear(duration: 3.0)) {
                                        longPressProgress = 1.0
                                    }
                                }
                            }
                            .onEnded { _ in
                                let touchDuration = touchStartTime?.timeIntervalSinceNow.magnitude ?? 0

                                // Reset visual state
                                withAnimation(.easeOut(duration: 0.2)) {
                                    longPressProgress = 0.0
                                    isLongPressing = false
                                }

                                // Determine action based on actual time held
                                if touchDuration >= 3.0 {
                                    // Long press completed - hard reset
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        pomodoroTimer.hardReset()
                                    }
                                } else {
                                    // Short tap - normal reset/skip
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if pomodoroTimer.isRunning {
                                            pomodoroTimer.resetTimer()
                                        } else {
                                            pomodoroTimer.skipToNextSession()
                                        }
                                    }
                                }

                                touchStartTime = nil
                            }
                    )
                }
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
