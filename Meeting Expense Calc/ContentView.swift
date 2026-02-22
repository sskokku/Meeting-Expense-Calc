//
//  ContentView.swift
//  Meeting Expense Calc
//
//  Created by Sashidhar Kokku on 2/22/26.
//

import SwiftUI

struct ContentView: View {
    @State private var timer = MeetingTimer()
    @State private var copied = false

    var body: some View {
        VStack(spacing: 20) {
            headerSection

            if timer.phase == .setup || timer.phase == .running || timer.phase == .paused {
                setupFormSection
            }

            if timer.phase != .setup {
                timerDisplaySection
            }

            controlsSection

            if timer.phase == .summary {
                summarySection
            }
        }
        .padding(24)
        .frame(minWidth: 400, minHeight: 450)
        .animation(.easeInOut, value: timer.phase)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.green)
            Text("Meeting Cost Calculator")
                .font(.title.bold())
        }
    }

    // MARK: - Setup Form

    private var setupFormSection: some View {
        GroupBox("Meeting Setup") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Meeting Name")
                        .frame(width: 120, alignment: .leading)
                    TextField("Optional", text: $timer.meetingName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: timer.meetingName) { _, newValue in
                            if newValue.count > 50 {
                                timer.meetingName = String(newValue.prefix(50))
                            }
                        }
                }

                HStack {
                    Text("Attendees")
                        .frame(width: 120, alignment: .leading)
                    Stepper("\(timer.attendees)", value: $timer.attendees, in: 1...50)
                }

                HStack {
                    Text("Hourly Rate")
                        .frame(width: 120, alignment: .leading)
                    TextField("Rate", value: $timer.hourlyRate, format: .currency(code: "USD"))
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: timer.hourlyRate) { _, newValue in
                            timer.hourlyRate = min(max(newValue, 1), 1000)
                        }
                }
            }
            .padding(.top, 4)
        }
        .disabled(timer.inputsLocked)
    }

    // MARK: - Timer Display

    private var timerDisplaySection: some View {
        VStack(spacing: 8) {
            Text(timer.formattedTime)
                .font(.system(size: 48, weight: .medium, design: .monospaced))
                .contentTransition(.numericText())
                .opacity(timer.phase == .paused ? 0.5 : 1.0)

            Text(timer.runningCost, format: .currency(code: "USD"))
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.green)
                .contentTransition(.numericText())

            Text("\(timer.costPerMinute, format: .currency(code: "USD"))/min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 12) {
            switch timer.phase {
            case .setup:
                Button("Start Meeting") {
                    timer.startMeeting()
                }
                .keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .running:
                Button("Pause") {
                    timer.pauseMeeting()
                }
                .keyboardShortcut(.space, modifiers: [])
                .controlSize(.large)

                Button("End Meeting") {
                    timer.endMeeting()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)

            case .paused:
                Button("Resume") {
                    timer.resumeMeeting()
                }
                .keyboardShortcut(.space, modifiers: [])
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("End Meeting") {
                    timer.endMeeting()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)

            case .summary:
                Button("New Meeting") {
                    timer.newMeeting()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    // MARK: - Summary

    private var summarySection: some View {
        GroupBox("Meeting Summary") {
            VStack(alignment: .leading, spacing: 8) {
                if !timer.meetingName.isEmpty {
                    summaryRow("Meeting", timer.meetingName)
                }
                summaryRow("Duration", timer.formattedTime)
                summaryRow("Attendees", "\(timer.attendees)")
                summaryRow("Hourly Rate", timer.hourlyRate.formatted(.currency(code: "USD")))
                summaryRow("Total Cost", timer.runningCost.formatted(.currency(code: "USD")))
                summaryRow("Cost/Person", timer.costPerPerson.formatted(.currency(code: "USD")))

                Divider()

                HStack {
                    Spacer()
                    Button {
                        copySummaryToClipboard()
                    } label: {
                        Label(copied ? "Copied!" : "Copy Summary", systemImage: copied ? "checkmark" : "doc.on.doc")
                    }
                    .controlSize(.small)
                }
            }
            .padding(.top, 4)
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .fontWeight(.medium)
        }
    }

    // MARK: - Clipboard

    private func copySummaryToClipboard() {
        var lines: [String] = ["Meeting Cost Summary", String(repeating: "-", count: 30)]
        if !timer.meetingName.isEmpty {
            lines.append("Meeting: \(timer.meetingName)")
        }
        lines.append("Duration: \(timer.formattedTime)")
        lines.append("Attendees: \(timer.attendees)")
        lines.append("Hourly Rate: \(timer.hourlyRate.formatted(.currency(code: "USD")))")
        lines.append("Total Cost: \(timer.runningCost.formatted(.currency(code: "USD")))")
        lines.append("Cost/Person: \(timer.costPerPerson.formatted(.currency(code: "USD")))")

        let text = lines.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

#Preview {
    ContentView()
}
