//
//  WorkoutHistoryView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        VStack {
            CalendarView()
        }
        .navigationTitle("Workout History")
    }
}