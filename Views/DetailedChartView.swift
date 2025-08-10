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
    case totalVolume(Exercise)
    case estimatedOneRepMax(Exercise)
    case totalReps(Exercise)
    case totalSets(Exercise)
    case timeUnderTension(Exercise)
    case averageIntensity(Exercise)
    case workoutsPerWeek
    case workoutDuration
    case weeklyExerciseVariety
    case muscleGroupDistribution
    case personalRecordsTimeline

    var id: String {
        switch self {
        case .highestWeight(let exercise):
            return "highestWeight_\(exercise.id)"
        case .totalVolume(let exercise):
            return "totalVolume_\(exercise.id)"
        case .estimatedOneRepMax(let exercise):
            return "estimatedOneRepMax_\(exercise.id)"
        case .totalReps(let exercise):
            return "totalReps_\(exercise.id)"
        case .totalSets(let exercise):
            return "totalSets_\(exercise.id)"
        case .timeUnderTension(let exercise):
            return "timeUnderTension_\(exercise.id)"
        case .averageIntensity(let exercise):
            return "averageIntensity_\(exercise.id)"
        case .workoutsPerWeek:
            return "workoutsPerWeek"
        case .workoutDuration:
            return "workoutDuration"
        case .weeklyExerciseVariety:
            return "weeklyExerciseVariety"
        case .muscleGroupDistribution:
            return "muscleGroupDistribution"
        case .personalRecordsTimeline:
            return "personalRecordsTimeline"
        }
    }
}

struct DetailedPersonalRecordsTimelineView: View {
    @EnvironmentObject var userProfileService: UserProfileService

    var body: some View {
        let records = userProfileService.userProfile.personalRecords.sorted { $0.date > $1.date }

        VStack {
            if records.isEmpty {
                Text("No personal records yet.")
                    .foregroundColor(.secondary)
            } else {
                List(records) { record in
                    VStack(alignment: .leading) {
                        Text(record.exerciseName)
                            .font(.headline)
                        Text("\(record.recordType.rawValue): \(record.value, specifier: "%.2f") \(userProfileService.userProfile.weightUnit.rawValue)")
                        Text("Date: \(record.date, formatter: DateFormatter.shortDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct DetailedWeeklyExerciseVarietyChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getWeeklyExerciseVarietyData(from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    BarMark(
                        x: .value("Week", $0.date, unit: .weekOfYear),
                        y: .value("Unique Exercises", $0.value)
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

struct DetailedMuscleGroupDistributionChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getMuscleGroupDistributionData(from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    SectorMark(
                        angle: .value("Count", $0.value),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Muscle Group", $0.name))
                }
            }
        }
    }
}

struct DetailedWorkoutDurationChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getWorkoutDurationData(from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Duration", $0.value / 60)
                    )
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue) min")
                            }
                        }
                    }
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

struct DetailedEstimatedOneRepMaxChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getEstimatedOneRepMaxData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("1RM", $0.value)
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

struct DetailedTotalRepsChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getTotalRepsData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    BarMark(
                        x: .value("Date", $0.date),
                        y: .value("Reps", $0.value)
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

struct DetailedTotalSetsChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getTotalSetsData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    BarMark(
                        x: .value("Date", $0.date),
                        y: .value("Sets", $0.value)
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

struct DetailedTimeUnderTensionChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getTimeUnderTensionData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Duration", $0.value)
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

struct DetailedAverageIntensityChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getAverageIntensityData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Intensity", $0.value)
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

struct DetailedTotalVolumeChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    @Binding var visibleDomain: ClosedRange<Date>?
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getTotalVolumeData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            if data.isEmpty {
                Text("No data available for this exercise.")
                    .foregroundColor(.secondary)
            } else {
                Chart(data) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Volume", $0.value)
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
            DetailedHighestWeightChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .totalVolume(let exercise):
            DetailedTotalVolumeChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .estimatedOneRepMax(let exercise):
            DetailedEstimatedOneRepMaxChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .totalReps(let exercise):
            DetailedTotalRepsChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .totalSets(let exercise):
            DetailedTotalSetsChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .timeUnderTension(let exercise):
            DetailedTimeUnderTensionChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .averageIntensity(let exercise):
            DetailedAverageIntensityChartView(exercise: exercise, visibleDomain: $visibleDomain)
        case .workoutsPerWeek:
            DetailedWorkoutsPerWeekChartView(visibleDomain: $visibleDomain)
        case .workoutDuration:
            DetailedWorkoutDurationChartView(visibleDomain: $visibleDomain)
        case .weeklyExerciseVariety:
            DetailedWeeklyExerciseVarietyChartView(visibleDomain: $visibleDomain)
        case .muscleGroupDistribution:
            DetailedMuscleGroupDistributionChartView()
        case .personalRecordsTimeline:
            DetailedPersonalRecordsTimelineView()
        }
    }

    private var chartData: [ChartDataPoint] {
        let chartManager = ChartManager()
        let unit = userProfileService.userProfile.weightUnit

        switch chartType {
        case .highestWeight(let exercise):
            return chartManager.getHighestWeightData(for: exercise, from: workoutManager.workoutHistory, unit: unit)
        case .totalVolume(let exercise):
            return chartManager.getTotalVolumeData(for: exercise, from: workoutManager.workoutHistory, unit: unit)
        case .estimatedOneRepMax(let exercise):
            return chartManager.getEstimatedOneRepMaxData(for: exercise, from: workoutManager.workoutHistory, unit: unit)
        case .totalReps(let exercise):
            return chartManager.getTotalRepsData(for: exercise, from: workoutManager.workoutHistory)
        case .totalSets(let exercise):
            return chartManager.getTotalSetsData(for: exercise, from: workoutManager.workoutHistory)
        case .timeUnderTension(let exercise):
            return chartManager.getTimeUnderTensionData(for: exercise, from: workoutManager.workoutHistory)
        case .averageIntensity(let exercise):
            return chartManager.getAverageIntensityData(for: exercise, from: workoutManager.workoutHistory, unit: unit)
        case .workoutsPerWeek:
            return chartManager.getWorkoutsPerWeekData(from: workoutManager.workoutHistory)
        case .workoutDuration:
            return chartManager.getWorkoutDurationData(from: workoutManager.workoutHistory)
        case .weeklyExerciseVariety:
            return chartManager.getWeeklyExerciseVarietyData(from: workoutManager.workoutHistory)
        case .muscleGroupDistribution:
            // This case is handled by pieChartData
            return []
        case .personalRecordsTimeline:
            // This case is handled by a List view, not a chart
            return []
        }
    }

    private var pieChartData: [PieChartDataPoint] {
        let chartManager = ChartManager()
        if case .muscleGroupDistribution = chartType {
            return chartManager.getMuscleGroupDistributionData(from: workoutManager.workoutHistory)
        }
        return []
    }

    private var chartTitle: String {
        switch chartType {
        case .highestWeight(let exercise):
            return "Highest Weight: \(exercise.name)"
        case .totalVolume(let exercise):
            return "Total Volume: \(exercise.name)"
        case .estimatedOneRepMax(let exercise):
            return "Estimated 1RM: \(exercise.name)"
        case .totalReps(let exercise):
            return "Total Reps: \(exercise.name)"
        case .totalSets(let exercise):
            return "Total Sets: \(exercise.name)"
        case .timeUnderTension(let exercise):
            return "Time Under Tension: \(exercise.name)"
        case .averageIntensity(let exercise):
            return "Average Intensity: \(exercise.name)"
        case .workoutsPerWeek:
            return "Workouts Per Week"
        case .workoutDuration:
            return "Workout Duration"
        case .weeklyExerciseVariety:
            return "Weekly Exercise Variety"
        case .muscleGroupDistribution:
            return "Muscle Group Distribution"
        case .personalRecordsTimeline:
            return "Personal Records"
        }
    }
}

struct DetailedHighestWeightChartView: View {
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

struct DetailedWorkoutsPerWeekChartView: View {
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
