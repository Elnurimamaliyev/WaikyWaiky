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
            Text("Your Visuals")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if entries.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 20) {
                    // Mood Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.blue)
                        
                        moodChartView
                    }
                    
                    Divider()
                    
                    // Sleep Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sleep Quality")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.purple)
                        
                        sleepChartView
                    }
                }
                .padding()
                .liquidGlass()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No check-ins yet")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .liquidGlass()
    }
    
    private var moodChartView: some View {
        Chart {
            ForEach(entries) { entry in
                BarMark(
                    x: .value("Time", entry.timeLabel),
                    y: .value("Mood", entry.mood)
                )
                .foregroundStyle(Color.blue.gradient)
                .annotation(position: .top) {
                    Text("\(entry.mood)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(height: 150)
        .chartYScale(domain: 0...5)
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5])
        }
    }
    
    private var sleepChartView: some View {
        Chart {
            ForEach(entries) { entry in
                BarMark(
                    x: .value("Time", entry.timeLabel),
                    y: .value("Sleep", entry.sleepQuality)
                )
                .foregroundStyle(Color.purple.gradient)
                .annotation(position: .top) {
                    Text("\(entry.sleepQuality)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.purple)
                }
            }
        }
        .frame(height: 150)
        .chartYScale(domain: 0...5)
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5])
        }
    }
}

#Preview {
    WeeklyMoodChart(entries: [
        CheckInEntry(date: Date(), mood: 4, sleepQuality: 3, nudge: nil),
        CheckInEntry(date: Date().addingTimeInterval(-3600), mood: 3, sleepQuality: 4, nudge: nil),
        CheckInEntry(date: Date().addingTimeInterval(-7200), mood: 5, sleepQuality: 5, nudge: nil)
    ])
    .padding()
}
