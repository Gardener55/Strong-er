//
//  WorkoutHistoryView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/WorkoutHistoryView.swift
import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var userProfileService: UserProfileService
    @State private var selectedPeriod: TimePeriod = .all
    
    enum TimePeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case all = "All Time"
    }
    
    var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .week:
            return workoutManager.workoutHistory.filter { workout in
                calendar.isDate(workout.date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .month:
            return workoutManager.workoutHistory.filter { workout in
                calendar.isDate(workout.date, equalTo: now, toGranularity: .month)
            }
        case .year:
            return workoutManager.workoutHistory.filter { workout in
                calendar.isDate(workout.date, equalTo: now, toGranularity: .year)
            }
        case .all:
            return workoutManager.workoutHistory
        }
    }
    
    var body: some View {
        VStack {
            // Period Selector
            Picker("Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Workout List
            List(filteredWorkouts.sorted { $0.date > $1.date }) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    WorkoutListRow(workout: workout)
                }
            }
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
    }
}