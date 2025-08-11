//
//  ChartsView.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/9/25.
//

import SwiftUI
import Charts

struct ChartsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedExercise: Exercise?
    @State private var showingDetail: ChartType?

    var body: some View {
        NavigationView {
            VStack {
                if workoutManager.workoutHistory.isEmpty {
                    Text("No workout history available.")
                        .foregroundColor(.secondary)
                } else {
                    ExercisePicker(selectedExercise: $selectedExercise)

                    ScrollView {
                        VStack {
                            if let selectedExercise = selectedExercise {
                                Button(action: {
                                    showingDetail = .highestWeight(selectedExercise)
                                }) {
                                    HighestWeightChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                                Button(action: {
                                    showingDetail = .totalVolume(selectedExercise)
                                }) {
                                    TotalVolumeChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                                Button(action: {
                                    showingDetail = .estimatedOneRepMax(selectedExercise)
                                }) {
                                    EstimatedOneRepMaxChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                                Button(action: {
                                    showingDetail = .totalReps(selectedExercise)
                                }) {
                                    TotalRepsChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                                Button(action: {
                                    showingDetail = .totalSets(selectedExercise)
                                }) {
                                    TotalSetsChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                                Button(action: {
                                    showingDetail = .timeUnderTension(selectedExercise)
                                }) {
                                    TimeUnderTensionChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                                Button(action: {
                                    showingDetail = .averageIntensity(selectedExercise)
                                }) {
                                    AverageIntensityChartView(exercise: selectedExercise)
                                }
                                .buttonStyle(HapticButtonStyle())
                            } else {
                                Text("Select an exercise to view charts.")
                                    .foregroundColor(.secondary)
                            }

                            Button(action: {
                                showingDetail = .workoutsPerWeek
                            }) {
                                WorkoutsPerWeekChartView()
                            }
                            .buttonStyle(HapticButtonStyle())

                            Button(action: {
                                showingDetail = .workoutDuration
                            }) {
                                WorkoutDurationChartView()
                            }
                            .buttonStyle(HapticButtonStyle())

                            Button(action: {
                                showingDetail = .weeklyExerciseVariety
                            }) {
                                WeeklyExerciseVarietyChartView()
                            }
                            .buttonStyle(HapticButtonStyle())

                            Button(action: {
                                showingDetail = .muscleGroupDistribution
                            }) {
                                MuscleGroupDistributionChartView()
                            }
                            .buttonStyle(HapticButtonStyle())

                            Button(action: {
                                showingDetail = .personalRecordsTimeline
                            }) {
                                PersonalRecordsTimelineView()
                            }
                            .buttonStyle(HapticButtonStyle())
                        }
                    }
                }
            }
            .sheet(item: $showingDetail) { chartType in
                NavigationView {
                    DetailedChartView(chartType: chartType)
                }
            }
            .navigationTitle("Progress Charts")
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = workoutManager.getUniqueExercises().first
                }
            }
        }
    }
}

struct PersonalRecordsTimelineView: View {
    @EnvironmentObject var userProfileService: UserProfileService

    var body: some View {
        VStack {
            Text("Personal Records")
                .font(.headline)
                .padding()

            if userProfileService.userProfile.personalRecords.isEmpty {
                Text("No personal records yet.")
                    .foregroundColor(.secondary)
            } else {
                Text("You have \(userProfileService.userProfile.personalRecords.count) personal records. Tap to view.")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WorkoutDurationChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getWorkoutDurationData(from: workoutManager.workoutHistory)

        VStack {
            Text("Workout Duration")
                .font(.headline)
                .padding()

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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct WeeklyExerciseVarietyChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getWeeklyExerciseVarietyData(from: workoutManager.workoutHistory)

        VStack {
            Text("Weekly Exercise Variety")
                .font(.headline)
                .padding()

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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct MuscleGroupDistributionChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getMuscleGroupDistributionData(from: workoutManager.workoutHistory)

        VStack {
            Text("Muscle Group Distribution")
                .font(.headline)
                .padding()

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



struct WorkoutsPerWeekChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getWorkoutsPerWeekData(from: workoutManager.workoutHistory)

        VStack {
            Text("Workouts Per Week")
                .font(.headline)
                .padding()

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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct HighestWeightChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getHighestWeightData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            Text("Highest Weight for \(exercise.name) (\(unit.rawValue))")
                .font(.headline)
                .padding()

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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct ExercisePicker: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedExercise: Exercise?

    var body: some View {
        Picker("Exercise", selection: $selectedExercise) {
            ForEach(workoutManager.getUniqueExercises(), id: \.self) { exercise in
                Text(exercise.name).tag(exercise as Exercise?)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
    }
}

struct TotalVolumeChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getTotalVolumeData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            Text("Total Volume: \(exercise.name)")
                .font(.headline)
                .padding()

            if data.isEmpty {
                Text("No data available.")
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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct EstimatedOneRepMaxChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getEstimatedOneRepMaxData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            Text("Estimated 1RM: \(exercise.name)")
                .font(.headline)
                .padding()

            if data.isEmpty {
                Text("No data available.")
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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct TotalRepsChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getTotalRepsData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            Text("Total Reps: \(exercise.name)")
                .font(.headline)
                .padding()

            if data.isEmpty {
                Text("No data available.")
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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct TotalSetsChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getTotalSetsData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            Text("Total Sets: \(exercise.name)")
                .font(.headline)
                .padding()

            if data.isEmpty {
                Text("No data available.")
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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct TimeUnderTensionChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getTimeUnderTensionData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            Text("Time Under Tension: \(exercise.name)")
                .font(.headline)
                .padding()

            if data.isEmpty {
                Text("No data available.")
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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}

struct AverageIntensityChartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let unit = userProfileService.userProfile.weightUnit
        let data = chartManager.getAverageIntensityData(for: exercise, from: workoutManager.workoutHistory, unit: unit)

        VStack {
            Text("Average Intensity: \(exercise.name)")
                .font(.headline)
                .padding()

            if data.isEmpty {
                Text("No data available.")
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
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
            }
        }
    }
}
