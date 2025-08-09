//
//  ProfileView.swift
//  FitnessTracker
//
//  Created by Evan Cohen on 8/8/25.
//


// Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfileService: UserProfileService
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                        
                        Text(userProfileService.userProfile.name.isEmpty ? "Your Name" : userProfileService.userProfile.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(userProfileService.userProfile.fitnessLevel.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stats Cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ProfileStatCard(title: "Weight", value: String(format: "%.1f", userProfileService.userProfile.weight) + " kg", icon: "scalemass")
                        ProfileStatCard(title: "Height", value: String(format: "%.0f", userProfileService.userProfile.height) + " cm", icon: "ruler")
                        ProfileStatCard(title: "Age", value: "\(userProfileService.userProfile.age)", icon: "calendar")
                        ProfileStatCard(title: "Weekly Goals", value: "\(userProfileService.userProfile.workoutDaysPerWeek) days", icon: "target")
                    }
                    
                    // Achievements Link
                    NavigationLink(destination: AchievementsView(userProfile: userProfileService.userProfile)) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Achievements")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Goals Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fitness Goals")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(userProfileService.userProfile.goals, id: \.self) { goal in
                                Text(goal.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                ProfileEditView(profile: $userProfileService.userProfile)
            }
        }
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $profile.name)
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Age", value: $profile.age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("Weight", value: $profile.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("Height", value: $profile.height, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Fitness Level") {
                    Picker("Fitness Level", selection: $profile.fitnessLevel) {
                        ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Goals") {
                    ForEach(UserProfile.FitnessGoal.allCases, id: \.self) { goal in
                        HStack {
                            Text(goal.rawValue)
                            Spacer()
                            if profile.goals.contains(goal) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if profile.goals.contains(goal) {
                                profile.goals.removeAll { $0 == goal }
                            } else {
                                profile.goals.append(goal)
                            }
                        }
                    }
                }
                
                Section("Workout Preferences") {
                    Stepper("Workouts per week: \(profile.workoutDaysPerWeek)", value: $profile.workoutDaysPerWeek, in: 1...7)
                    
                    VStack(alignment: .leading) {
                        Text("Session Duration: \(profile.sessionDuration) minutes")
                        Slider(value: Binding(
                            get: { Double(profile.sessionDuration) },
                            set: { profile.sessionDuration = Int($0) }
                        ), in: 15...120, step: 15)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
