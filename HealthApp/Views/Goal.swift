import SwiftUI

struct UpdateGoalRequest: Codable {
    let goal: String
}

struct GoalView: View {
    @Binding var selectedGoal: String?
    @Binding var isPresented: Bool
    @State private var showAlert = false
    @State private var showSaveAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pick a Goal")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    GoalButton(title: "Lose Fat/Weight", color: Color.purple.opacity(0.8), selectedGoal: $selectedGoal)
                    GoalButton(title: "Gain Muscle", color: Color.purple.opacity(0.6), selectedGoal: $selectedGoal)
                    GoalButton(title: "Maintenance", color: Color.purple.opacity(0.4), selectedGoal: $selectedGoal)
                    
                    Text("Please avoid changing goal too often to allow for optimal success")
                        .padding()
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .opacity(0.7)

                    Button(action: saveGoal) {
                        Text("Save Goal")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 20)
                    }
                    .alert(isPresented: $showSaveAlert) {
                        Alert(
                            title: Text("Goal Saved"),
                            message: Text("Your selected goal has been saved."),
                            dismissButton: .default(Text("OK")) {
                                isPresented = false // Dismiss the view
                            }
                        )
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9)) // Background for content
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .padding()
            .background(Color.black.ignoresSafeArea()) // Main background color
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Selected Goal"),
                    message: Text("You have selected \(selectedGoal ?? "No Goal")"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveGoal() {
        guard let goal = selectedGoal else {
            showAlert = true
            return
        }

        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            showAlert = true
            return
        }

        let goalRequest = UpdateGoalRequest(goal: goal)
        guard let url = URL(string: "\(constants.baseURL)/users/updateGoal") else {
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(goalRequest)
            request.httpBody = jsonData
        } catch {
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                showAlert = true
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                showAlert = true
                return
            }

            DispatchQueue.main.async {
                showSaveAlert = true
            }
        }.resume()
    }
}

struct GoalButton: View {
    let title: String
    let color: Color
    @Binding var selectedGoal: String?
    
    var body: some View {
        Button(action: {
            selectedGoal = title
        }) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(10)
                .opacity(selectedGoal == title ? 1 : 0.5)
                .padding(.vertical, 10)
        }
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(selectedGoal: .constant(nil), isPresented: .constant(true))
    }
}
