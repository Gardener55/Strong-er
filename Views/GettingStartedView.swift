import SwiftUI

struct GettingStartedView: View {
    @EnvironmentObject var userProfileService: UserProfileService
    @State private var selection = 0

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                WelcomePageView(selection: $selection).tag(0)
                PersonalInfoPageView(selection: $selection, profile: $userProfileService.userProfile).tag(1)
                VitalsPageView(selection: $selection, profile: $userProfileService.userProfile).tag(2)
                GoalsPageView(selection: $selection, profile: $userProfileService.userProfile).tag(3)
                WeeklyGoalsPageView(selection: $selection, profile: $userProfileService.userProfile).tag(4)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

struct WelcomePageView: View {
    @Binding var selection: Int

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Strong-er")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Let's get your profile set up.")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: {
                withAnimation {
                    selection = 1
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(HapticButtonStyle())
            .padding()
        }
    }
}

struct PersonalInfoPageView: View {
    @Binding var selection: Int
    @Binding var profile: UserProfile

    var body: some View {
        VStack {
            Text("Tell us about yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $profile.name)

                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Age", value: $profile.age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }

            Spacer()

            Button(action: {
                withAnimation {
                    selection = 2
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(HapticButtonStyle())
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct VitalsPageView: View {
    @Binding var selection: Int
    @Binding var profile: UserProfile
    @State private var displayedWeight: Double = 70.0

    var body: some View {
        VStack {
            Text("Your Vitals")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section(header: Text("Measurements")) {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", value: $displayedWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $profile.height, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    Picker("Weight Units", selection: $profile.weightUnit) {
                        ForEach(UserProfile.WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }

            Spacer()

            Button(action: {
                if profile.weightUnit == .pounds {
                    profile.weight = displayedWeight / 2.20462
                } else {
                    profile.weight = displayedWeight
                }
                withAnimation {
                    selection = 3
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(HapticButtonStyle())
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            if profile.weightUnit == .pounds {
                displayedWeight = profile.weight * 2.20462
            } else {
                displayedWeight = profile.weight
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct GoalsPageView: View {
    @Binding var selection: Int
    @Binding var profile: UserProfile

    var body: some View {
        VStack {
            Text("What are your goals?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section(header: Text("Fitness Level")) {
                    Picker("Fitness Level", selection: $profile.fitnessLevel) {
                        ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Goals")) {
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
            }

            Spacer()

            Button(action: {
                withAnimation {
                    selection = 4
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(HapticButtonStyle())
            .padding()
        }
    }
}

struct WeeklyGoalsPageView: View {
    @Binding var selection: Int
    @Binding var profile: UserProfile

    var body: some View {
        VStack {
            Text("Weekly Commitment")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section(header: Text("Workout Preferences")) {
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

            Spacer()

            Button(action: {
                profile.isProfileSetupComplete = true
            }) {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(HapticButtonStyle())
            .padding()
        }
    }
}
