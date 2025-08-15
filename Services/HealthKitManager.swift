//
//  HealthKitManager.swift
//  Strong-er
//
//  Created by Evan Cohen on 8/11/25.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.example.Strong-er", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
            return
        }

        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]

        let typesToRead: Set = [
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }

    func checkAuthorizationStatus() -> Bool {
        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)
        return status == .sharingAuthorized
    }

    func saveWorkout(workout: Workout, completion: @escaping (Bool, Error?) -> Void) {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor

        let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: workoutConfiguration,
                                       device: .local())

        let startDate = workout.date
        let endDate = startDate.addingTimeInterval(workout.duration ?? 0.0)

        builder.beginCollection(withStart: startDate) { (success, error) in
            guard success else {
                completion(false, error)
                return
            }
        }

        let workoutEvents = self.workoutEvents(for: workout)

        if !workoutEvents.isEmpty {
            builder.addWorkoutEvents(workoutEvents) { (success, error) in
                guard success else {
                    completion(false, error)
                    return
                }
            }
        }

        // Add a total energy burned sample
        let totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 300) // Placeholder for total calories
        let calorieSample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, quantity: totalEnergyBurned, start: startDate, end: endDate)

        builder.add([calorieSample]) { (success, error) in
            guard success else {
                completion(false, error)
                return
            }

            builder.endCollection(withEnd: endDate) { (success, error) in
                guard success else {
                    completion(false, error)
                    return
                }

                builder.finishWorkout { (hkWorkout, error) in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }

    private func workoutEvents(for workout: Workout) -> [HKWorkoutEvent] {
        var events: [HKWorkoutEvent] = []
        var currentTime = workout.date

        guard !workout.exercises.isEmpty else { return events }

        // Assuming each exercise takes an equal fraction of the total duration.
        // A more accurate implementation would require per-exercise durations.
        let exerciseDuration = (workout.duration ?? 0.0) / Double(workout.exercises.count)

        guard exerciseDuration > 0 else { return events }

        for exercise in workout.exercises {
            let exerciseEndDate = currentTime.addingTimeInterval(exerciseDuration)

            let event = HKWorkoutEvent(type: .segment,
                                       dateInterval: DateInterval(start: currentTime, end: exerciseEndDate),
                                       metadata: [HKMetadataKeyWorkoutBrandName: "Strong-er", "Exercise": exercise.exercise.name])
            events.append(event)

            currentTime = exerciseEndDate
        }

        return events
    }
}
