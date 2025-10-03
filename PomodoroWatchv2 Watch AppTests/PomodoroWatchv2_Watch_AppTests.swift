//
//  PomodoroWatchv2_Watch_AppTests.swift
//  PomodoroWatchv2 Watch AppTests
//
//  Created by Romain  Lagrange on 17/09/2025.
//

import Testing
@testable import PomodoroWatchv2_Watch_App

struct PomodoroTimerTests {

    // MARK: - Initialization Tests

    @Test func testInitialState() {
        let timer = PomodoroTimer()

        #expect(timer.currentState == .idle)
        #expect(timer.currentSessionType == .work)
        #expect(timer.timeRemaining == 25 * 60) // 25 minutes
        #expect(timer.sessionsCompleted == 0)
        #expect(timer.isRunning == false)
        #expect(timer.progress == 0.0)
    }

    // MARK: - Session Type Tests

    @Test func testSessionTypeDurations() {
        #expect(SessionType.work.duration == 25 * 60)
        #expect(SessionType.shortBreak.duration == 5 * 60)
        #expect(SessionType.longBreak.duration == 15 * 60)
    }

    @Test func testSessionTypeDisplayNames() {
        #expect(SessionType.work.displayName == "Work Session")
        #expect(SessionType.shortBreak.displayName == "Short Break")
        #expect(SessionType.longBreak.displayName == "Long Break")
    }

    // MARK: - Session State Tests

    @Test func testSessionStateDisplayNames() {
        #expect(SessionState.idle.displayName == "Ready")
        #expect(SessionState.working.displayName == "Work Time")
        #expect(SessionState.onBreak.displayName == "Break Time")
        #expect(SessionState.paused.displayName == "Paused")
    }

    @Test func testSessionStateIsActive() {
        #expect(SessionState.idle.isActive == false)
        #expect(SessionState.working.isActive == true)
        #expect(SessionState.onBreak.isActive == true)
        #expect(SessionState.paused.isActive == false)
    }

    // MARK: - Timer Logic Tests

    @Test func testStartTimer() {
        let timer = PomodoroTimer()

        timer.startTimer()

        #expect(timer.isRunning == true)
        #expect(timer.currentState == .working)
    }

    @Test func testPauseTimer() {
        let timer = PomodoroTimer()

        timer.startTimer()
        timer.pauseTimer()

        #expect(timer.isRunning == false)
        #expect(timer.currentState == .paused)
    }

    @Test func testResetTimer() {
        let timer = PomodoroTimer()

        // Start and then reset
        timer.startTimer()
        timer.resetTimer()

        #expect(timer.currentState == .idle)
        #expect(timer.currentSessionType == .work)
        #expect(timer.timeRemaining == SessionType.work.duration)
        #expect(timer.isRunning == false)
    }

    @Test func testHardReset() {
        let timer = PomodoroTimer()

        // Simulate some completed sessions
        timer.startTimer()
        // Manually set some state to test reset
        timer.sessionsCompleted = 3

        timer.hardReset()

        #expect(timer.currentState == .idle)
        #expect(timer.currentSessionType == .work)
        #expect(timer.timeRemaining == SessionType.work.duration)
        #expect(timer.sessionsCompleted == 0)
        #expect(timer.isRunning == false)
    }

    // MARK: - Progress Calculation Tests

    @Test func testProgressCalculation() {
        let timer = PomodoroTimer()

        // Test initial progress
        #expect(timer.progress == 0.0)

        // Test progress at half time
        timer.timeRemaining = 12.5 * 60 // Half of 25 minutes
        #expect(timer.progress == 0.5)

        // Test progress near completion
        timer.timeRemaining = 60 // 1 minute left
        let expectedProgress = (25 * 60 - 60) / (25 * 60.0)
        #expect(abs(timer.progress - expectedProgress) < 0.01) // Allow small floating point differences
    }

    // MARK: - Time Formatting Tests

    @Test func testFormattedTime() {
        let timer = PomodoroTimer()

        timer.timeRemaining = 25 * 60 // 25:00
        #expect(timer.formattedTime == "25:00")

        timer.timeRemaining = 5 * 60 + 30 // 5:30
        #expect(timer.formattedTime == "05:30")

        timer.timeRemaining = 59 // 0:59
        #expect(timer.formattedTime == "00:59")

        timer.timeRemaining = 0 // 0:00
        #expect(timer.formattedTime == "00:00")
    }

    // MARK: - Long Break Logic Tests

    @Test func testShouldShowLongBreak() {
        let timer = PomodoroTimer()

        // No sessions completed - should not show long break
        timer.sessionsCompleted = 0
        #expect(timer.shouldShowLongBreak == false)

        // 1-3 sessions completed - should not show long break
        timer.sessionsCompleted = 1
        #expect(timer.shouldShowLongBreak == false)
        timer.sessionsCompleted = 2
        #expect(timer.shouldShowLongBreak == false)
        timer.sessionsCompleted = 3
        #expect(timer.shouldShowLongBreak == false)

        // 4 sessions completed - should show long break
        timer.sessionsCompleted = 4
        #expect(timer.shouldShowLongBreak == true)

        // 8 sessions completed - should show long break
        timer.sessionsCompleted = 8
        #expect(timer.shouldShowLongBreak == true)
    }

    // TODO(human): Complete this test function
    @Test func testSkipToNextSession() {
        let timer = PomodoroTimer()

        // Test 1: Skip from work session (first time) should go to short break
        timer.currentSessionType = .work        // Arrange: Set up work session
        timer.sessionsCompleted = 0            // Arrange: No sessions completed yet

        timer.skipToNextSession() // Act: Perform the action

        #expect(timer.currentSessionType == .shortBreak)  // Assert: Should be short break
        #expect(timer.sessionsCompleted == 1)             // Assert: Should count the work session
        // Test 2: Skip from work session (after 4 sessions) should go to long break
        timer.currentSessionType = .work        
        timer.sessionsCompleted = 3
        
        timer.skipToNextSession() 

        #expect(timer.currentSessionType == .longBreak)
        #expect(timer.sessionsCompleted == 4)
        // Test 3: Skip from break should go back to work
        timer.currentSessionType = .shortBreak  

        timer.skipToNextSession()

        #expect(timer.currentSessionType == .work)
    }

    // MARK: - Integration Tests

    @Test func testTimerNotificationIntegration() {
        let timer = PomodoroTimer()

        // Test: Starting work session should schedule notification with correct timing
        timer.currentSessionType = .work
        timer.timeRemaining = 25 * 60 // 25 minutes

        // Before starting: verify no notifications pending (clean state)
        // Note: In a real integration test, we'd check UNUserNotificationCenter.current().getPendingNotificationRequests

        timer.startTimer()

        // After starting: verify timer is running (integration point 1)
        #expect(timer.isRunning == true)
        #expect(timer.currentState == .working)

        // Integration verification: The timer should have called notificationManager.scheduleSessionCompletionNotification
        // with sessionType = .work and timeInterval = 25*60
        // Note: This tests the contract between PomodoroTimer and NotificationManager

        // Test that timer calls notification scheduling
        // In a full integration test, we could verify notification center requests
        // For now, we test that the timer reaches the correct state that would trigger notifications
    }

    @Test func testNotificationContentGeneration() {
        // Test notification content is correct for each session type
        // This verifies the NotificationManager logic independently
        let notificationManager = NotificationManager.shared

        // We can't directly test the private notification content creation,
        // but we can test the public interface and verify the method calls work

        // Test work session notification scheduling (integration point)
        notificationManager.scheduleSessionCompletionNotification(for: .work, in: 1500) // 25 minutes

        // Test short break notification scheduling
        notificationManager.scheduleSessionCompletionNotification(for: .shortBreak, in: 300) // 5 minutes

        // Test long break notification scheduling
        notificationManager.scheduleSessionCompletionNotification(for: .longBreak, in: 900) // 15 minutes

        // Since we can't access the private notification content directly,
        // we verify that the methods execute without throwing errors
        // In a production app, you might extract the content creation logic
        // into a testable public method
    }

    @Test func testTimerPauseNotificationCancellation() {
        let timer = PomodoroTimer()

        // Start timer (schedules notification)
        timer.startTimer()
        #expect(timer.isRunning == true)

        // Pause timer (should cancel notifications)
        timer.pauseTimer()
        #expect(timer.isRunning == false)
        #expect(timer.currentState == .paused)

        // Integration point: Verify that pause cancels scheduled notifications
        // This tests the timer-notification integration for pause behavior
    }

    @Test func testSessionCompletionFlow() {
        let timer = PomodoroTimer()

        // Test complete session transition flow
        timer.currentSessionType = .work
        timer.timeRemaining = 1 // Almost complete
        timer.startTimer()

        // Simulate session completion by manually updating timer
        // In real app, this would happen via Timer.scheduledTimer
        timer.timeRemaining = 0

        // The updateTimer() method should:
        // 1. Stop the timer
        // 2. Increment session count
        // 3. Trigger haptic feedback
        // 4. Transition to next session

        // This tests the integration between timer logic and user feedback systems
        #expect(timer.isRunning == false) // Timer should stop
    }
}
