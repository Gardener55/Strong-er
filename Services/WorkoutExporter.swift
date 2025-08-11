import Foundation

class WorkoutExporter {
    func exportWorkouts(workoutManager: WorkoutManager) throws -> URL {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        let fileName = "workouts-\(Date().formatted(.iso8601)).csv"
        let fileURL = temporaryDirectory.appendingPathComponent(fileName)

        var csvString = "Date,Exercise Name,Set Number,Reps,Weight,Weight Unit,Rest Time\n"

        let workouts = workoutManager.workouts
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for workout in workouts {
            let dateString = dateFormatter.string(from: workout.date)
            for exercise in workout.exercises {
                for (index, set) in exercise.sets.enumerated() {
                    let line = "\(dateString),\(exercise.exercise.name),\(index + 1),\(set.reps),\(set.weight),\(set.weightUnit.rawValue),\(set.restTime)\n"
                    csvString.append(line)
                }
            }
        }

        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
