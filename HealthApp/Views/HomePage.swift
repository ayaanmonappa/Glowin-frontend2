import SwiftUI

struct HomePage: View {
    @State private var showBMICalculationView = false
    @State private var showGoalView = false
    @State private var showRecommendedGoalsView = false
    @State private var selectedGoal: String? = nil
    @State private var isShowingLogin = false
    @State private var recommendedGoals: [GeneratedGoal.GoalPublic] = []
    @State private var measurements: [Measurement.MeasurementPublic] = []
    @State private var showStatisticsView = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }

                    VStack(spacing: 20) {
                        // Current Stats Section
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.blue)
                                    Text("Current Stats")
                                        .font(.title3)
                                        .bold()
                                    Spacer()
                                    Button(action: {
                                        showBMICalculationView = true
                                    }) {
                                        Text("Edit")
                                            .padding(10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(5)
                                    }
                                }
                                Text("Input/view your measurement stats.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(15)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }

                        // Recommended Goals Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.blue)
                                Text("Recommended Goals")
                                    .font(.title3)
                                    .bold()
                                Spacer()

                                Button(action: {
                                    // Prompt if no measurements or goal are set
                                    checkUserDataAndGenerateGoals()
                                }) {
                                    Text("Generate")
                                        .padding(10)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }

                                Button(action: {
                                    let token = getUserToken()
                                    fetchGoals(userToken: token)
                                    showRecommendedGoalsView = true
                                }) {
                                    Text("View")
                                        .padding(10)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                            Text("Based on your stats, here are some goals you might want to consider.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(15)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Current Goal Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("Current Goal:")
                            Spacer()
                            Button(action: {
                                showGoalView = true
                            }) {
                                Text("Edit")
                                    .padding(5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }

                        HStack {
                            Text(selectedGoal ?? "No goal selected")
                                .padding(.leading, 10)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(15)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Navigation Buttons for Recipes and Workouts
                    HStack(spacing: 20) {
                        NavigationLink(destination: RecipeListView()) {
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                Text("Recipes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                        }

                        NavigationLink(destination: WorkoutPlanView(userToken: getUserToken())) {
                            VStack {
                                Image(systemName: "figure.walk")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.white)
                                Text("Workouts")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }

                    // Statistics Button
                    NavigationLink(destination: StatisticsView()) {
                        VStack {
                            Image(systemName: "chart.pie.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .foregroundColor(.white)
                            Text("Statistics")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryPurple)
                        .cornerRadius(10)
                    }

                    // Sign Out Button
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "userToken")
                        isShowingLogin = true
                    }) {
                        Text("Sign Out")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isShowingLogin) {
                LoginPage()
            }
            .fullScreenCover(isPresented: $showBMICalculationView) {
                BMICalculationView(showBMICalculationView: $showBMICalculationView)
            }
            .fullScreenCover(isPresented: $showRecommendedGoalsView) {
                RecommendedGoalsView(goals: $recommendedGoals)
            }
            .sheet(isPresented: $showGoalView) {
                GoalView(selectedGoal: $selectedGoal, isPresented: $showGoalView)
            }
            .onAppear {
                let token = getUserToken()
                // Call these functions with their completion handlers
                fetchCurrentGoal(userToken: token) { _ in }
                fetchMeasurements(userToken: token) { _ in }
                fetchGoals(userToken: token)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func getUserToken() -> String {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            print("Error: User token not found in HomePage")  // Debugging info
            return ""
        }
        return token
    }

    private func checkUserDataAndGenerateGoals() {
        let token = getUserToken()
        // Fetch current measurements and goal
        fetchMeasurements(userToken: token) { measurements in
            if measurements.isEmpty {
                errorMessage = "Please input your measurements before generating goals."
            } else {
                fetchCurrentGoal(userToken: token) { goal in
                    // Safely unwrap 'goal'
                    if let goal = goal, !goal.isEmpty {
                        // Both measurements and goal are present, proceed with generation
                        generateGoals(userToken: token)
                        errorMessage = nil
                    } else {
                        errorMessage = "Please set a goal before generating recommendations."
                    }
                }
            }
        }
    }

    private func fetchCurrentGoal(userToken: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(constants.baseURL)/users/goal") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let goal = try? JSONDecoder().decode(UpdateGoalRequest.self, from: data) {
                DispatchQueue.main.async {
                    self.selectedGoal = goal.goal
                    completion(goal.goal)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func generateGoals(userToken: String) {
        guard let url = URL(string: "\(constants.baseURL)/goals/generate") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let goals = try JSONDecoder().decode([GeneratedGoal.GoalPublic].self, from: data)
                    DispatchQueue.main.async {
                        self.recommendedGoals = goals
                    }
                } catch {
                    print("Error decoding goals: \(error)")
                }
            }
        }.resume()
    }

    private func fetchGoals(userToken: String) {
        guard let url = URL(string: "\(constants.baseURL)/goals") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let goals = try decoder.decode([GeneratedGoal.GoalPublic].self, from: data)
                    DispatchQueue.main.async {
                        self.recommendedGoals = goals
                    }
                } catch {
                    print("Error decoding goals: \(error)")
                }
            }
        }.resume()
    }

    private func fetchMeasurements(userToken: String, completion: @escaping ([Measurement.MeasurementPublic]) -> Void) {
        guard let url = URL(string: "\(constants.baseURL)/measurements") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let measurements = try decoder.decode([Measurement.MeasurementPublic].self, from: data)
                    DispatchQueue.main.async {
                        self.measurements = measurements
                        completion(measurements)
                    }
                } catch {
                    print("Error decoding measurements: \(error)")
                    completion([])
                }
            } else {
                completion([])
            }
        }.resume()
    }
}




struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
