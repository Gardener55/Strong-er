//
//  WorkoutImporter.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25.
//

import Foundation

class WorkoutImporter {

    enum ImportError: Error {
        case invalidCSVFormat
        case exerciseNotFound(name: String)
        case invalidData(message: String)
    }

    func importWorkouts(from url: URL, exerciseDatabase: ExerciseDatabase, workoutManager: WorkoutManager) throws {
        let data = try String(contentsOf: url)
        let rows = data.components(separatedBy: "\n").filter { !$0.isEmpty }

        guard rows.count > 1 else {
            throw ImportError.invalidCSVFormat
        }

        let header = rows.first!.components(separatedBy: ",")
        let dataRows = rows.dropFirst()

        var workoutsByDate: [Date: Workout] = [:]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for row in dataRows {
            let columns = row.components(separatedBy: ",")
            if columns.count != header.count {
                continue // Skip malformed rows
            }

            let rowData = Dictionary(uniqueKeysWithValues: zip(header, columns))

            guard let dateString = rowData["Date"],
                  let date = dateFormatter.date(from: dateString),
                  let exerciseName = rowData["Exercise Name"],
                  let setOrderString = rowData["Set Order"],
                  let setOrder = Int(setOrderString),
                  let weightString = rowData["Weight"],
                  let weight = Double(weightString),
                  let repsString = rowData["Reps"],
                  let reps = Int(repsString)
            else {
                throw ImportError.invalidData(message: "Invalid data in row: \(row)")
            }

            guard let exercise = exerciseDatabase.searchExercises(exerciseName).first else {
                throw ImportError.exerciseNotFound(name: exerciseName)
            }

            let workoutSet = WorkoutSet(reps: reps, weight: weight)

            if workoutsByDate[date] == nil {
                let workoutName = rowData["Workout Name"] ?? "Imported Workout"
                workoutsByDate[date] = Workout(name: workoutName, date: date)
            }

            if let exerciseIndex = workoutsByDate[date]!.exercises.firstIndex(where: { $0.exercise.name == exercise.name }) {
                workoutsByDate[date]!.exercises[exerciseIndex].sets.append(workoutSet)
            } else {
                let workoutExercise = WorkoutExercise(exercise: exercise, sets: [workoutSet])
                workoutsByDate[date]!.exercises.append(workoutExercise)
            }
        }

        let importedWorkouts = Array(workoutsByDate.values)
        workoutManager.importWorkouts(importedWorkouts)
    }
}
