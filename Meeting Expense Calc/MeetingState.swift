//
//  MeetingState.swift
//  Meeting Expense Calc
//
//  Created by Sashidhar Kokku on 2/22/26.
//

import SwiftUI
import Combine

enum MeetingPhase: Equatable {
    case setup
    case running
    case paused
    case summary
}

@Observable
class MeetingTimer {
    var attendees: Int = 4
    var hourlyRate: Double = 150
    var meetingName: String = ""
    var phase: MeetingPhase = .setup
    var elapsedSeconds: Int = 0

    private var timerCancellable: AnyCancellable?

    // MARK: - Computed Properties

    var runningCost: Double {
        let costPerSecond = (Double(attendees) * hourlyRate) / 3600.0
        return costPerSecond * Double(elapsedSeconds)
    }

    var costPerMinute: Double {
        (Double(attendees) * hourlyRate) / 60.0
    }

    var costPerPerson: Double {
        guard attendees > 0 else { return 0 }
        return runningCost / Double(attendees)
    }

    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var inputsLocked: Bool {
        phase != .setup
    }

    // MARK: - Actions

    func startMeeting() {
        guard phase == .setup else { return }
        elapsedSeconds = 0
        phase = .running
        startTimer()
    }

    func pauseMeeting() {
        guard phase == .running else { return }
        phase = .paused
        stopTimer()
    }

    func resumeMeeting() {
        guard phase == .paused else { return }
        phase = .running
        startTimer()
    }

    func endMeeting() {
        guard phase == .running || phase == .paused else { return }
        phase = .summary
        stopTimer()
    }

    func newMeeting() {
        phase = .setup
        elapsedSeconds = 0
        meetingName = ""
        stopTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
