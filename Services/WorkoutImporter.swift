//
//  WorkoutImporter.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/8/25.
//

import Foundation

class WorkoutImporter {
    
    enum ImportError: Error, LocalizedError {
        case invalidCSVFormat
        case exerciseNotFound(name: String)
        case invalidData(message: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidCSVFormat:
                return "Invalid CSV Format. The file should contain a header and at least one row of data."
            case .exerciseNotFound(let name):
                return "Exercise not found: \(name). Please make sure all exercises in the CSV exist in the app's library."
            case .invalidData(let message):
                return "Invalid data in CSV: \(message)"
            }
        }
    }
    
    func importWorkouts(from url: URL, exerciseDatabase: ExerciseDatabase, workoutManager: WorkoutManager) throws {
        let secured = url.startAccessingSecurityScopedResource()
        defer {
            if secured {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try String(contentsOf: url)
        let normalizedData = data.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        let rows = normalizedData.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        guard rows.count > 1 else {
            throw ImportError.invalidCSVFormat
        }
        
        let header = rows.first!.components(separatedBy: ",")
        let dataRows = rows.dropFirst()
        
        var workoutsByDate: [Date: Workout] = [:]
        
        for row in dataRows {
            let columns = row.components(separatedBy: ",")
            if columns.count != header.count {
                continue // Skip malformed rows
            }
            
            let rowData = Dictionary(uniqueKeysWithValues: zip(header, columns))
            
            guard let dateString = rowData["Date"],
                  let date = parseDate(from: dateString),
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

    private func parseDate(from dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd HH:mm:ss",
            "M/d/yy HH:mm"
        ].map { format -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter
        }

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}
