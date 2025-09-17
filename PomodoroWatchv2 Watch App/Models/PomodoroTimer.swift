import Foundation
import Combine

class PomodoroTimer: ObservableObject {
    // MARK: - Published Properties
    @Published var currentState: SessionState = .idle
    @Published var currentSessionType: SessionType = .work
    @Published var timeRemaining: TimeInterval = 25 * 60 // Start with 25 minutes
    @Published var sessionsCompleted: Int = 0
    @Published var isRunning: Bool = false

    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?

    // MARK: - Computed Properties
    var progress: Double {
        let totalTime = currentSessionType.duration
        let elapsed = totalTime - timeRemaining
        return elapsed / totalTime
    }

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var shouldShowLongBreak: Bool {
        return sessionsCompleted > 0 && sessionsCompleted % 4 == 0
    }

    // MARK: - Initialization
    init() {
        resetTimer()
    }

    // MARK: - Public Methods

    func startTimer() {
        // Don't start if already running
        guard !isRunning else { return }

        // Update running state
        isRunning = true
        startTime = Date()



        // TODO(human): Implement state transition logic
        if currentSessionType == .work {
            currentState = .working
        } else {
            currentState = .onBreak
        }

        // Start the countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    func pauseTimer() {
        // Only pause if currently running
        guard isRunning else { return }

        // Stop the countdown timer
        stopInternalTimer()

        // Update state
        isRunning = false
        currentState = .paused

        // Note: We keep timeRemaining as-is so we can resume from here
    }

    // TODO(human): Implement reset timer logic
    func resetTimer() {
        currentState = .idle
        currentSessionType = .work
        timeRemaining = currentSessionType.duration
        isRunning = false
        stopInternalTimer()
    }

    func skipToNextSession() {
        // Stop current timer if running
        if isRunning {
            stopInternalTimer()
            isRunning = false
        }

        // If current session is work, count it as completed
        if currentSessionType == .work {
            sessionsCompleted += 1
        }

        // Transition to next session
        transitionToNextSession()
    }

    // MARK: - Private Methods
    private func transitionToNextSession() {
        // Determine what the next session should be
        if currentSessionType == .work {
            // Implement break selection logic
            currentSessionType = shouldShowLongBreak ? .longBreak : .shortBreak
        } else {
            // Coming from any break, go back to work
            currentSessionType = .work
        }

        // Reset timer for new session
        timeRemaining = currentSessionType.duration
        currentState = .idle
    }

    private func updateTimer() {
        // Decrease time by 1 second
        timeRemaining -= 1

        // Check if session is complete
        if timeRemaining <= 0 {
            // Session finished - handle transitions
            stopInternalTimer()
            isRunning = false

            // Implement session completion logic
            if currentSessionType == .work {
                sessionsCompleted += 1
            }

            // Always transition to next session (work→break or break→work)
            transitionToNextSession()
        }
    }

    private func stopInternalTimer() {
        timer?.invalidate()
        timer = nil
    }
}