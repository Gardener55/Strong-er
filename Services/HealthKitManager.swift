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

        builder.beginCollection(withStart: workout.date) { (success, error) in
            guard success else {
                completion(false, error)
                return
            }
        }

        let samples = self.samples(for: workout)

        builder.add(samples) { (success, error) in
            guard success else {
                completion(false, error)
                return
            }

            builder.endCollection(withEnd: workout.date.addingTimeInterval(workout.duration ?? 0.0)) { (success, error) in
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

    private func samples(for workout: Workout) -> [HKSample] {
        var samples: [HKSample] = []

        // Create a sample for each exercise
        for exercise in workout.exercises {
            let exerciseType = HKWorkoutActivityType.traditionalStrengthTraining
            let startDate = workout.date // Assuming all exercises start at the same time
            let endDate = startDate.addingTimeInterval(workout.duration ?? 0.0) // Assuming duration is for the whole workout

            let workoutEvent = HKWorkoutEvent(type: .segment, dateInterval: DateInterval(start: startDate, end: endDate), metadata: [:])

            let totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 200) // Placeholder value

            let exerciseSample = HKWorkout(activityType: .traditionalStrengthTraining,
                                           start: startDate,
                                           end: endDate,
                                           workoutEvents: [workoutEvent],
                                           totalEnergyBurned: totalEnergyBurned,
                                           totalDistance: nil,
                                           device: .local(),
                                           metadata: [HKMetadataKeyWorkoutBrandName: "Strong-er"])
            samples.append(exerciseSample)
        }

        return samples
    }
}
