import Foundation

enum SessionState: String, CaseIterable {
    case idle = "idle"
    case working = "working"
    case onBreak = "onBreak"
    case paused = "paused"

    var displayName: String {
        switch self {
        case .idle:
            return "Ready"
        case .working:
            return "Work Time"
        case .onBreak:
            return "Break Time"
        case .paused:
            return "Paused"
        }
    }

    var isActive: Bool {
        return self == .working || self == .onBreak
    }
}

enum SessionType: String, CaseIterable {
    case work = "work"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"

    var duration: TimeInterval {
        switch self {
        case .work:
            return 25 * 60 // 25 minutes
        case .shortBreak:
            return 5 * 60  // 5 minutes
        case .longBreak:
            return 15 * 60 // 15 minutes
        }
    }

    var displayName: String {
        switch self {
        case .work:
            return "Work Session"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
}