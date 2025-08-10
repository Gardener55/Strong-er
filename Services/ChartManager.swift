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

    func getHighestWeightData(for exercise: Exercise, from workouts: [Workout], unit: UserProfile.WeightUnit) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { workout in
            workout.exercises.contains { $0.exercise.id == exercise.id }
        }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let highestWeightInKg = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }
                .compactMap { $0.weight }
                .max() ?? 0

            let displayWeight = unit == .pounds ? highestWeightInKg * 2.20462 : highestWeightInKg

            return ChartDataPoint(date: workout.date, value: displayWeight)
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

    func getTotalVolumeData(for exercise: Exercise, from workouts: [Workout], unit: UserProfile.WeightUnit) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { $0.exercises.contains { $0.exercise.id == exercise.id } }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let totalVolumeInKg = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }
                .reduce(0) { $0 + (Double($1.reps) * ($1.weight ?? 0)) }

            let displayVolume = unit == .pounds ? totalVolumeInKg * 2.20462 : totalVolumeInKg
            return ChartDataPoint(date: workout.date, value: displayVolume)
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getEstimatedOneRepMaxData(for exercise: Exercise, from workouts: [Workout], unit: UserProfile.WeightUnit) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { $0.exercises.contains { $0.exercise.id == exercise.id } }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let max1RMInKg = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }
                .compactMap { set -> Double? in
                    guard let weight = set.weight, set.reps > 0 else { return nil }
                    return weight * (1 + (Double(set.reps) / 30.0)) // Epley formula
                }
                .max() ?? 0

            let display1RM = unit == .pounds ? max1RMInKg * 2.20462 : max1RMInKg
            return ChartDataPoint(date: workout.date, value: display1RM)
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getTotalRepsData(for exercise: Exercise, from workouts: [Workout]) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { $0.exercises.contains { $0.exercise.id == exercise.id } }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let totalReps = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }
                .reduce(0) { $0 + $1.reps }

            return ChartDataPoint(date: workout.date, value: Double(totalReps))
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getTotalSetsData(for exercise: Exercise, from workouts: [Workout]) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { $0.exercises.contains { $0.exercise.id == exercise.id } }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let totalSets = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .map { $0.sets.count }
                .reduce(0, +)

            return ChartDataPoint(date: workout.date, value: Double(totalSets))
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getTimeUnderTensionData(for exercise: Exercise, from workouts: [Workout]) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { $0.exercises.contains { $0.exercise.id == exercise.id } }

        let dataPoints = relevantWorkouts.map { workout -> ChartDataPoint in
            let totalDuration = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }
                .compactMap { $0.duration }
                .reduce(0, +)

            return ChartDataPoint(date: workout.date, value: totalDuration)
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getAverageIntensityData(for exercise: Exercise, from workouts: [Workout], unit: UserProfile.WeightUnit) -> [ChartDataPoint] {
        let relevantWorkouts = workouts.filter { $0.exercises.contains { $0.exercise.id == exercise.id } }

        let dataPoints = relevantWorkouts.compactMap { workout -> ChartDataPoint? in
            let sets = workout.exercises
                .filter { $0.exercise.id == exercise.id }
                .flatMap { $0.sets }

            let totalVolumeInKg = sets.reduce(0) { $0 + (Double($1.reps) * ($1.weight ?? 0)) }
            let totalReps = sets.reduce(0) { $0 + $1.reps }

            guard totalReps > 0 else { return nil }

            let averageIntensityInKg = totalVolumeInKg / Double(totalReps)
            let displayIntensity = unit == .pounds ? averageIntensityInKg * 2.20462 : averageIntensityInKg

            return ChartDataPoint(date: workout.date, value: displayIntensity)
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getWorkoutDurationData(from workouts: [Workout]) -> [ChartDataPoint] {
        let dataPoints = workouts.compactMap { workout -> ChartDataPoint? in
            guard let duration = workout.duration else { return nil }
            return ChartDataPoint(date: workout.date, value: duration)
        }
        return dataPoints.sorted { $0.date < $1.date }
    }

    func getWeeklyExerciseVarietyData(from workouts: [Workout]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let weeklyWorkouts = Dictionary(grouping: workouts) { workout in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.date))!
        }

        let dataPoints = weeklyWorkouts.map { (week, workoutsInWeek) -> ChartDataPoint in
            let uniqueExercises = Set(workoutsInWeek.flatMap { $0.exercises.map { $0.exercise.name } })
            return ChartDataPoint(date: week, value: Double(uniqueExercises.count))
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    func getMuscleGroupDistributionData(from workouts: [Workout]) -> [PieChartDataPoint] {
        let recentWorkouts = workouts.filter { $0.date > Date().addingTimeInterval(-30 * 24 * 60 * 60) }
        var muscleGroupCounts: [String: Int] = [:]

        for workout in recentWorkouts {
            for workoutExercise in workout.exercises {
                for muscleGroup in workoutExercise.exercise.muscleGroups {
                    muscleGroupCounts[muscleGroup.rawValue, default: 0] += 1
                }
            }
        }

        return muscleGroupCounts.map { PieChartDataPoint(name: $0.key, value: Double($0.value)) }
    }
}

struct PieChartDataPoint: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
}
