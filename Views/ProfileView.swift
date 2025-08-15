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
                        ProfileStatCard(title: "Weight", value: weightString, icon: "scalemass")
                        ProfileStatCard(title: "Height", value: heightString, icon: "ruler")
                        ProfileStatCard(title: "Age", value: "\(userProfileService.userProfile.age)", icon: "calendar")
                        ProfileStatCard(title: "Weekly Goals", value: "\(userProfileService.userProfile.workoutDaysPerWeek) days", icon: "target")
                    }
                    
                    // Achievements Link
                    NavigationLink(destination: AchievementsView(userProfile: $userProfileService.userProfile)) {
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
                    .buttonStyle(HapticButtonStyle())

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
                    .buttonStyle(HapticButtonStyle())
                }
            }
            .sheet(isPresented: $showingSettings) {
                ProfileEditView(profile: $userProfileService.userProfile)
            }
        }
    }

    private var weightString: String {
        let weight = userProfileService.userProfile.weight
        let unit = userProfileService.userProfile.weightUnit
        if unit == .pounds {
            let weightInLbs = weight * 2.20462
            return String(format: "%.1f lbs", weightInLbs)
        } else {
            return String(format: "%.1f kg", weight)
        }
    }

    private var heightString: String {
        let height = userProfileService.userProfile.height
        let unit = userProfileService.userProfile.heightUnit
        if unit == .feetInches {
            let heightInInches = height / 2.54
            let feet = Int(heightInInches / 12)
            let inches = Int(round(heightInInches.truncatingRemainder(dividingBy: 12)))
            return "\(feet) ft \(inches) in"
        } else {
            return String(format: "%.0f cm", height)
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

    // State for text fields
    @State private var weightString: String = ""
    @State private var heightCmString: String = ""
    @State private var heightFeetString: String = ""
    @State private var heightInchesString: String = ""
    
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
                        Text("Weight (\(profile.weightUnit.rawValue))")
                        Spacer()
                        TextField("Weight", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if profile.heightUnit == .centimeters {
                        HStack {
                            Text("Height (cm)")
                            Spacer()
                            TextField("Height", text: $heightCmString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    } else {
                        HStack {
                            Text("Height (ft)")
                            Spacer()
                            TextField("Feet", text: $heightFeetString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Height (in)")
                            Spacer()
                            TextField("Inches", text: $heightInchesString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
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
                        Button(action: {
                            if profile.goals.contains(goal) {
                                profile.goals.removeAll { $0 == goal }
                            } else {
                                profile.goals.append(goal)
                            }
                        }) {
                            HStack {
                                Text(goal.rawValue)
                                Spacer()
                                if profile.goals.contains(goal) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(HapticButtonStyle())
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
                        saveProfileData()
                        dismiss()
                    }
                    .buttonStyle(HapticButtonStyle())
                }
            }
            .onAppear(perform: setupTextFields)
        }
    }

    private func setupTextFields() {
        // Weight
        if profile.weightUnit == .pounds {
            let weightInLbs = profile.weight * 2.20462
            weightString = String(format: "%.1f", weightInLbs)
        } else {
            weightString = String(format: "%.1f", profile.weight)
        }

        // Height
        if profile.heightUnit == .centimeters {
            heightCmString = String(format: "%.0f", profile.height)
        } else {
            let heightInInches = profile.height / 2.54
            let feet = Int(heightInInches / 12)
            let inches = Int(round(heightInInches.truncatingRemainder(dividingBy: 12)))
            heightFeetString = "\(feet)"
            heightInchesString = "\(inches)"
        }
    }

    private func saveProfileData() {
        // Save Weight
        if let weightValue = Double(weightString) {
            if profile.weightUnit == .pounds {
                profile.weight = weightValue / 2.20462
            } else {
                profile.weight = weightValue
            }
        }

        // Save Height
        if profile.heightUnit == .centimeters {
            if let heightValue = Double(heightCmString) {
                profile.height = heightValue
            }
        } else {
            let feet = Double(heightFeetString) ?? 0
            let inches = Double(heightInchesString) ?? 0
            let totalInches = (feet * 12) + inches
            profile.height = totalInches * 2.54
        }
    }
}
