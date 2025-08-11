//
//  ThisWeekHistoryView.swift
//  Strong-er
//
//  Created by Jules on 8/11/25.
//

import SwiftUI

struct ThisWeekHistoryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.presentationMode) var presentationMode

    var thisWeekWorkouts: [Workout] {
        workoutManager.workoutHistory.filter {
            Calendar.current.isDateInThisWeek($0.date)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if thisWeekWorkouts.isEmpty {
                    Text("No workouts this week.")
                        .foregroundColor(.secondary)
                } else {
                    List(thisWeekWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutHistoryRow(workout: workout)
                        }
                    }
                }
            }
            .navigationTitle("This Week's History")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.buttonStyle(HapticButtonStyle()))
        }
    }
}

extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(workout.exercises.count) exercises")
                    .font(.caption)

                if let duration = workout.duration {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}
