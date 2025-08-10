//
//  DetailedChartView.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/9/25.
//

import SwiftUI
import Charts

enum ChartType: Identifiable {
    case highestWeight(Exercise)
    case workoutsPerWeek

    var id: String {
        switch self {
        case .highestWeight(let exercise):
            return "highestWeight_\(exercise.id)"
        case .workoutsPerWeek:
            return "workoutsPerWeek"
        }
    }
}

struct DetailedChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService

    let chartType: ChartType

    @State private var visibleDomain: ClosedRange<Date>?

    var body: some View {
        VStack {
            chartView
                .padding()

            ChartZoomControlView(visibleDomain: $visibleDomain, allData: chartData.map { $0.date })
        }
        .navigationTitle(chartTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var chartView: some View {
        switch chartType {
        case .highestWeight(let exercise):
            HighestWeightChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .workoutsPerWeek:
            WorkoutsPerWeekChartView(visibleDomain: $visibleDomain)
        }
    }

    private var chartData: [ChartDataPoint] {
        let chartManager = ChartManager()
        switch chartType {
        case .highestWeight(let exercise):
            let unit = userProfileService.userProfile.weightUnit
            return chartManager.getHighestWeightData(for: exercise, from: workoutManager.workoutHistory, unit: unit)
        case .workoutsPerWeek:
            return chartManager.getWorkoutsPerWeekData(from: workoutManager.workoutHistory)
        }
    }

    private var chartTitle: String {
        switch chartType {
        case .highestWeight(let exercise):
            return "Highest Weight: \(exercise.name)"
        case .workoutsPerWeek:
            return "Workouts Per Week"
        }
    }
}

struct HighestWeightChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getHighestWeightData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Weight", $0.value)
                    )
                    PointMark(
                        x: .value("Date", $0.date),
                        y: .value("Weight", $0.value)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day().year())
                    }
                }
                .chartXScale(domain: visibleDomain ?? (data.first?.date ?? Date())...(data.last?.date ?? Date()))
                .chartScrollableAxes(.horizontal)
            }
        }
    }
}

struct ChartZoomControlView: View {
    @Binding var visibleDomain: ClosedRange<Date>?
    let allData: [Date]

    var body: some View {
        HStack {
            Button("Zoom Out") {
                if let domain = visibleDomain, let fullDomain = getFullDomain() {
                    let newLowerBound = calendar.date(byAdding: .month, value: -1, to: domain.lowerBound) ?? fullDomain.lowerBound
                    let newUpperBound = calendar.date(byAdding: .month, value: 1, to: domain.upperBound) ?? fullDomain.upperBound
                    visibleDomain = newLowerBound...newUpperBound
                } else {
                    visibleDomain = getFullDomain()
                }
            }

            Button("Zoom In") {
                if let domain = visibleDomain {
                    let newLowerBound = calendar.date(byAdding: .month, value: 1, to: domain.lowerBound) ?? domain.lowerBound
                    let newUpperBound = calendar.date(byAdding: .month, value: -1, to: domain.upperBound) ?? domain.upperBound
                    if newLowerBound < newUpperBound {
                        visibleDomain = newLowerBound...newUpperBound
                    }
                }
            }

            Button("Reset") {
                visibleDomain = getFullDomain()
            }
        }
        .padding()
    }

    private var calendar: Calendar {
        Calendar.current
    }

    private func getFullDomain() -> ClosedRange<Date>? {
        guard let minDate = allData.min(), let maxDate = allData.max() else {
            return nil
        }
        return minDate...maxDate
    }
}

struct WorkoutsPerWeekChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getWorkoutsPerWeekData(from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    BarMark(
                        x: .value("Week", $0.date, unit: .weekOfYear),
                        y: .value("Count", $0.value)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day().year())
                    }
                }
                .chartXScale(domain: visibleDomain ?? (data.first?.date ?? Date())...(data.last?.date ?? Date()))
                .chartScrollableAxes(.horizontal)
            }
        }
    }
}
