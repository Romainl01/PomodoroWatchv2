import Foundation
import UserNotifications
import WatchKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    // Request notification permissions
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    // Schedule notification for session completion
    func scheduleSessionCompletionNotification(for sessionType: SessionType, in timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()

        // Set notification content based on session type
        switch sessionType {
        case .work:
            content.title = "Work Session Complete!"
            content.body = "Great job! Time for a well-deserved break."
            content.sound = .default
        case .shortBreak:
            content.title = "Break Complete!"
            content.body = "Ready to get back to work? Let's go!"
            content.sound = .default
        case .longBreak:
            content.title = "Long Break Complete!"
            content.body = "Refreshed and ready for the next session!"
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "session-complete-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    // Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Trigger haptic feedback
    func triggerHapticFeedback(for type: HapticType) {
        DispatchQueue.main.async {
            switch type {
            case .sessionComplete:
                WKInterfaceDevice.current().play(.success)
            case .sessionStart:
                WKInterfaceDevice.current().play(.start)
            case .sessionPause:
                WKInterfaceDevice.current().play(.stop)
            }
        }
    }
}

enum HapticType {
    case sessionComplete
    case sessionStart
    case sessionPause
}