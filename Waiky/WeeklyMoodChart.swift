//
//  WeeklyMoodChart.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI
import Charts

struct WeeklyMoodChart: View {
    let entries: [CheckInEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Week")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if entries.isEmpty {
                VStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No check-ins yet this week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                Chart {
                    ForEach(entries) { entry in
                        BarMark(
                            x: .value("Day", entry.dayOfWeek),
                            y: .value("Mood", entry.mood)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...5)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [1, 2, 3, 4, 5])
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    WeeklyMoodChart(entries: [
        CheckInEntry(date: Date(), mood: 4, sleepQuality: 3, nudge: nil),
        CheckInEntry(date: Date().addingTimeInterval(-86400), mood: 3, sleepQuality: 4, nudge: nil),
        CheckInEntry(date: Date().addingTimeInterval(-172800), mood: 5, sleepQuality: 5, nudge: nil)
    ])
    .padding()
}
