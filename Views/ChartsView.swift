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
                                HighestWeightChartView(exercise: selectedExercise)
                            } else {
                                Text("Select an exercise to view charts.")
                                    .foregroundColor(.secondary)
                            }

                            WorkoutsPerWeekChartView()
                        }
                    }
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
    let exercise: Exercise
    private let chartManager = ChartManager()

    var body: some View {
        let data = chartManager.getHighestWeightData(for: exercise, from: workoutManager.workoutHistory)

        VStack {
            Text("Highest Weight for \(exercise.name)")
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
