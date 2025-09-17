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
    private let notificationManager = NotificationManager.shared
    private let persistenceManager = PersistenceManager.shared

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
        if let savedState = persistenceManager.loadTimerState() {
            let sessionType = savedState.sessionType
            let timeRemaining = savedState.timeRemaining
            let sessionsCompleted = savedState.sessionsCompleted
            let wasRunning = savedState.wasRunning
            let timeSinceLastSave = savedState.timeSinceLastSave

            // Calculate actual remaining time if timer was running
            var actualTimeRemaining = timeRemaining
            if wasRunning {
                actualTimeRemaining = timeRemaining - timeSinceLastSave
            }

            // Check if session completed while app was closed
            if actualTimeRemaining <= 0 {
                // Session finished - start fresh
                resetTimer()
                return
            }

            // Restore all saved values
            currentSessionType = sessionType
            self.timeRemaining = actualTimeRemaining
            self.sessionsCompleted = sessionsCompleted
            currentState = .idle    // Always start in idle state
            isRunning = false       // Never auto-resume running timer
        } else {
            // No saved data - start fresh
            resetTimer()
        }
    }

    // MARK: - Public Methods

    func startTimer() {
        // Don't start if already running
        guard !isRunning else { return }

        // Update running state
        isRunning = true
        startTime = Date()

        // Set current state based on session type
        if currentSessionType == .work {
            currentState = .working
        } else {
            currentState = .onBreak
        }

        // Schedule notification for when session completes
        notificationManager.scheduleSessionCompletionNotification(
            for: currentSessionType,
            in: timeRemaining
        )

        // Add haptic feedback for session start
        notificationManager.triggerHapticFeedback(for: .sessionStart)

        // Start the countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }

        // Save state when timer starts
        saveCurrentState()
    }

    func pauseTimer() {
        // Only pause if currently running
        guard isRunning else { return }

        // Stop the countdown timer
        stopInternalTimer()

        // Update state
        isRunning = false
        currentState = .paused

        // Cancel scheduled notification since we're pausing
        notificationManager.cancelAllNotifications()

        // Add haptic feedback for pause
        notificationManager.triggerHapticFeedback(for: .sessionPause)

        // Note: We keep timeRemaining as-is so we can resume from here

        // Save state when paused
        saveCurrentState()
    }

    func resetTimer() {
        currentState = .idle
        currentSessionType = .work
        timeRemaining = currentSessionType.duration
        isRunning = false
        stopInternalTimer()

        // Cancel any scheduled notifications
        notificationManager.cancelAllNotifications()

        // Clear saved state since we're resetting to defaults
        persistenceManager.clearSavedState()
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
    private func saveCurrentState() {
        persistenceManager.saveTimerState(
            sessionType: currentSessionType,
            timeRemaining: timeRemaining,
            sessionsCompleted: sessionsCompleted,
            isRunning: isRunning
        )
    }

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

        // Save state after session transition
        saveCurrentState()
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

            // Add haptic feedback for session completion
            notificationManager.triggerHapticFeedback(for: .sessionComplete)

            // Always transition to next session (work→break or break→work)
            transitionToNextSession()
        }
    }

    private func stopInternalTimer() {
        timer?.invalidate()
        timer = nil
    }
}