import SwiftUI //page not needed

struct WorkoutPlanSelectionView: View {
    @State private var selectedDays: Int = 3
    @State private var showWorkoutPlan: Bool = false
    @State private var userToken: String?

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Your Workout Plan")
                    .font(.largeTitle)
                    .padding()

                Picker("Select Days", selection: $selectedDays) {
                    Text("3 Days").tag(3)
                    Text("4 Days").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    if let token = UserDefaults.standard.string(forKey: "userToken") {
                        self.userToken = token
                        showWorkoutPlan = true
                    } else {
                        // Handle the case where there is no user token
                        print("No user token found")
                    }
                }) {
                    Text("Generate Plan")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showWorkoutPlan) {
                    if let token = userToken {
                        WorkoutPlanView(userToken: token)
                    } else {
                        Text("Unable to load workout plan.")
                    }
                }
            }
            .navigationBarTitle("Workout Plan")
        }
    }
}

struct WorkoutPlanSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPlanSelectionView()
    }
}
