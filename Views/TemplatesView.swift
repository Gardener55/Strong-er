//
//  TemplatesView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/TemplatesView.swift
import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var exerciseDatabase: ExerciseDatabase
    @State private var showingCreateTemplate = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workoutManager.templates) { template in
                    TemplateRow(template: template) {
                        workoutManager.startWorkout(template)
                    }
                }
                .onDelete(perform: deleteTemplates)
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateTemplate = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CreateWorkoutView(sourceView: .templates)
                    .environmentObject(exerciseDatabase)
            }
        }
    }
    
    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            let template = workoutManager.templates[index]
            workoutManager.deleteTemplate(template)
        }
    }
}

struct TemplateRow: View {
    let template: Workout
    let onStart: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                
                Text("\(template.exercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(Array(Set(template.exercises.flatMap { $0.exercise.muscleGroups })).prefix(3), id: \.self) { muscle in
                        Text(muscle.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Button("Start", action: onStart)
                .buttonStyle(HapticButtonStyle())
                .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}