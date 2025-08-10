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
                                HighestWeightChartView(exercise: selectedExercise)
                                    .onTapGesture {
                                        showingDetail = .highestWeight(selectedExercise)
                                    }
                            } else {
                                Text("Select an exercise to view charts.")
                                    .foregroundColor(.secondary)
                            }

                            WorkoutsPerWeekChartView()
                                .onTapGesture {
                                    showingDetail = .workoutsPerWeek
                                }
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
