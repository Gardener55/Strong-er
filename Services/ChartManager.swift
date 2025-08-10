//
//  ChartManager.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/9/25.
//

import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

class ChartManager {

    func getHighestWeightData(for exercise: Exercise, from workouts: [Workout]) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { workout in
            workout.exercises.contains { $0.exercise.id == exercise.id }
        }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let highestWeight = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }
                .compactMap { $0.weight }
                .max() ?? 0

            return ChartDataPoint(date: workout.date, value: highestWeight)
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getWorkoutsPerWeekData(from workouts: [Workout]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let weeklyWorkouts = Dictionary(grouping: workouts) { workout in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.date))!
        }

        let dataPoints = weeklyWorkouts.map { (week, workoutsInWeek) -> ChartDataPoint in
            return ChartDataPoint(date: week, value: Double(workoutsInWeek.count))
        }

        return dataPoints.sorted { $0.date < $1.date }
    }
}
