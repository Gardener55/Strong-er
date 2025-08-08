//
//  WorkoutManager.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Services/WorkoutManager.swift
import Foundation

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var templates: [Workout] = []
    @Published var currentWorkout: Workout?
    @Published var workoutHistory: [Workout] = []
    
    private let userDefaults = UserDefaults.standard
    private let workoutsKey = "SavedWorkouts"
    private let templatesKey = "WorkoutTemplates"
    
    init() {
        loadData()
    }
    
    func startWorkout(_ workout: Workout) {
        var newWorkout = workout
        newWorkout.date = Date()
        newWorkout.isTemplate = false
        // Reset completion status
        for i in 0..<newWorkout.exercises.count {
            for j in 0..<newWorkout.exercises[i].sets.count {
                newWorkout.exercises[i].sets[j].completed = false
            }
        }
        currentWorkout = newWorkout
    }
    
    func completeWorkout() {
        guard var workout = currentWorkout else { return }
        workout.duration = Date().timeIntervalSince(workout.date)
        workouts.append(workout)
        workoutHistory.append(workout)
        currentWorkout = nil
        saveData()
    }
    
    func saveTemplate(_ workout: Workout) {
        var template = workout
        template.isTemplate = true
        template.date = Date()
        templates.append(template)
        saveData()
    }
    
    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
        workoutHistory.removeAll { $0.id == workout.id }
        saveData()
    }
    
    func deleteTemplate(_ template: Workout) {
        templates.removeAll { $0.id == template.id }
        saveData()
    }
    
    private func saveData() {
        if let workoutsData = try? JSONEncoder().encode(workouts) {
            userDefaults.set(workoutsData, forKey: workoutsKey)
        }
        if let templatesData = try? JSONEncoder().encode(templates) {
            userDefaults.set(templatesData, forKey: templatesKey)
        }
    }
    
    private func loadData() {
        if let workoutsData = userDefaults.data(forKey: workoutsKey),
           let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: workoutsData) {
            workouts = decodedWorkouts
            workoutHistory = decodedWorkouts
        }
        
        if let templatesData = userDefaults.data(forKey: templatesKey),
           let decodedTemplates = try? JSONDecoder().decode([Workout].self, from: templatesData) {
            templates = decodedTemplates
        }
    }
    
    // Analytics
    func getWorkoutStats() -> WorkoutStats {
        let totalWorkouts = workoutHistory.count
        let totalDuration = workoutHistory.compactMap { $0.duration }.reduce(0, +)
        let averageDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
        
        let thisWeekWorkouts = workoutHistory.filter { workout in
            Calendar.current.isDate(workout.date, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
        
        return WorkoutStats(
            totalWorkouts: totalWorkouts,
            totalDuration: totalDuration,
            averageDuration: averageDuration,
            thisWeekWorkouts: thisWeekWorkouts
        )
    }
}

struct WorkoutStats {
    let totalWorkouts: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let thisWeekWorkouts: Int
}