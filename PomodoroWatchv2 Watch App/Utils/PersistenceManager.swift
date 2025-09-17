import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private init() {}

    // UserDefaults keys
    private enum Keys {
        static let currentSessionType = "currentSessionType"
        static let timeRemaining = "timeRemaining"
        static let sessionsCompleted = "sessionsCompleted"
        static let isRunning = "isRunning"
        static let lastSaveTime = "lastSaveTime"
    }

    // Save current timer state
    func saveTimerState(
        sessionType: SessionType,
        timeRemaining: TimeInterval,
        sessionsCompleted: Int,
        isRunning: Bool
    ) {
        let defaults = UserDefaults.standard

        defaults.set(sessionType.rawValue, forKey: Keys.currentSessionType)
        defaults.set(timeRemaining, forKey: Keys.timeRemaining)
        defaults.set(sessionsCompleted, forKey: Keys.sessionsCompleted)
        defaults.set(isRunning, forKey: Keys.isRunning)
        defaults.set(Date(), forKey: Keys.lastSaveTime)
    }

    // Load saved timer state
    func loadTimerState() -> (sessionType: SessionType, timeRemaining: TimeInterval, sessionsCompleted: Int, wasRunning: Bool, timeSinceLastSave: TimeInterval)? {
        let defaults = UserDefaults.standard

        // Check if we have saved data
        guard defaults.object(forKey: Keys.currentSessionType) != nil else {
            return nil
        }

        // Load saved values from UserDefaults
        let sessionTypeString = defaults.string(forKey: Keys.currentSessionType)
        let timeRemaining = defaults.double(forKey: Keys.timeRemaining)
        let sessionsCompleted = defaults.integer(forKey: Keys.sessionsCompleted)
        let wasRunning = defaults.bool(forKey: Keys.isRunning)
        let lastSaveTime = defaults.object(forKey: Keys.lastSaveTime) as? Date

        // Convert string back to SessionType enum
        guard let sessionTypeString = sessionTypeString,
              let sessionType = SessionType(rawValue: sessionTypeString),
              let lastSaveTime = lastSaveTime else {
            return nil
        }

        // Calculate time elapsed since last save
        let timeSinceLastSave = Date().timeIntervalSince(lastSaveTime)

        return (
            sessionType: sessionType,
            timeRemaining: timeRemaining,
            sessionsCompleted: sessionsCompleted,
            wasRunning: wasRunning,
            timeSinceLastSave: timeSinceLastSave
        )
    }

    // Clear saved state
    func clearSavedState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.currentSessionType)
        defaults.removeObject(forKey: Keys.timeRemaining)
        defaults.removeObject(forKey: Keys.sessionsCompleted)
        defaults.removeObject(forKey: Keys.isRunning)
        defaults.removeObject(forKey: Keys.lastSaveTime)
    }
}