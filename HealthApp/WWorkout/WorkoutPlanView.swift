import SwiftUI
import WebKit

struct WorkoutPlanView: View {
    let userToken: String
    @State private var selectedDays: Int = 3
    @State private var workoutPlan: [WorkoutDay] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedGIF: GIFUrlWrapper?
    @State private var isLocked: Bool = false
    @State private var hasValidMeasurements = false
    @State private var hasValidGoal = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Select Split:")
                    .font(.headline)
                Spacer()
                Picker("Split", selection: $selectedDays) {
                    Text("3-Day Split").tag(3)
                    Text("4-Day Split").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(isLocked)
            }
            .padding()

            Button(action: {
                validateUserData() // Call validation function here
            }) {
                Text("Generate Workout Plan")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLocked ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .disabled(isLocked)


            if isLoading {
                ProgressView("Generating Workout Plan...")
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(workoutPlan.sorted(by: { $0.dayName < $1.dayName }), id: \.dayName) { day in
                    NavigationLink(destination: WorkoutDetailView(workoutDay: day, selectedGIF: $selectedGIF)) {
                        Text(day.dayName)
                            .font(.headline)
                            .padding(.vertical, 5)
                    }
                }
            }

            Button(action: toggleLock) {
                Text(isLocked ? "Unlock Workout Plan" : "Lock Workout Plan")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLocked ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .navigationTitle("Workout Plan")
        .sheet(item: $selectedGIF) { gifWrapper in
            if let url = gifWrapper.url {
                FullGIFView(url: url)
            } else {
                Text("Invalid GIF URL")
            }
        }
        .onAppear {
            loadStoredWorkoutPlan()
        }
    }

    private func generateWorkoutPlan() {
        isLoading = true
        errorMessage = nil
        
        // Debug: Log selectedDays and URL
        print("Generating workout plan for \(selectedDays) days")
        
        guard let url = URL(string: "https://8174-219-74-229-42.ngrok-free.app/workouts/generate?days=\(selectedDays)") else {
            print("Invalid URL")
            errorMessage = "Invalid URL"
            return
        }
        
        print("Requesting URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                // Debug: Check for errors in network call
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                // Debug: Check the response and status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                        return
                    }
                }

                guard let data = data else {
                    print("No data received")
                    errorMessage = "No data received"
                    return
                }

                // Debug: Print raw data
                print("Received Data: \(String(describing: String(data: data, encoding: .utf8)))")

                do {
                    workoutPlan = try JSONDecoder().decode([WorkoutDay].self, from: data)
                    storeWorkoutPlan()
                    print("Workout Plan Generated Successfully")
                } catch {
                    print("Decoding error: \(error)")
                    errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func storeWorkoutPlan() {
        if let encoded = try? JSONEncoder().encode(workoutPlan) {
            UserDefaults.standard.set(encoded, forKey: "workoutPlan-\(selectedDays)")
        }
    }
    private func validateUserData() {
        fetchUserMeasurements { success in
            if success {
                fetchUserGoal { goalSuccess in
                    if goalSuccess {
                        generateWorkoutPlan()
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Please set your goal before generating a workout plan."
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Please enter your measurements before generating a workout plan."
                }
            }
        }
    }
    
    

    private func loadStoredWorkoutPlan() {
        if let savedWorkoutPlan = UserDefaults.standard.data(forKey: "workoutPlan-\(selectedDays)") {
            if let decodedWorkoutPlan = try? JSONDecoder().decode([WorkoutDay].self, from: savedWorkoutPlan) {
                self.workoutPlan = decodedWorkoutPlan
                self.isLocked = true // Assume locked if a plan is loaded
            }
        }
    }

    private func toggleLock() {
        isLocked.toggle()
        if !isLocked {
            UserDefaults.standard.removeObject(forKey: "workoutPlan-\(selectedDays)")
        }
    }
    // Function to fetch user measurements and determine if they are valid
      private func fetchUserMeasurements(completion: @escaping (Bool) -> Void) {
            guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
                print("User token not found")
                completion(false)
                return
            }

            guard let url = URL(string: "\(constants.baseURL)\(Endpoints.measurements)") else {
                print("Invalid URL")
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching measurements: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let data = data else {
                    print("No data received from server")
                    completion(false)
                    return
                }

                // Debug: Print the raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }

                do {
                    // Use a JSONDecoder and set the date decoding strategy
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601 // Adjust this if the date format is different

                    // Decode the data into an array of `MeasurementCreate`
                    let measurements = try decoder.decode([MeasurementCreate].self, from: data)
                    
                    DispatchQueue.main.async {
                        hasValidMeasurements = !measurements.isEmpty
                        completion(!measurements.isEmpty)
                    }
                } catch {
                    // Debug: Print the error to help diagnose the issue
                    print("Error decoding measurements: \(error.localizedDescription)")
                    completion(false)
                }
            }.resume()
        }


        // Function to fetch user goal and determine if it is valid
        private func fetchUserGoal(completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/goal") else {
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching goal: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let data = data else {
                    completion(false)
                    return
                }

                do {
                    let goalResponse = try JSONDecoder().decode(UpdateGoalRequest.self, from: data)
                    DispatchQueue.main.async {
                        hasValidGoal = !goalResponse.goal.isEmpty
                        completion(!goalResponse.goal.isEmpty)
                    }
                } catch {
                    print("Error decoding goal: \(error.localizedDescription)")
                    completion(false)
                }
            }.resume()
        }
}


struct WorkoutDetailView: View {
    let workoutDay: WorkoutDay
    @Binding var selectedGIF: GIFUrlWrapper?

    var body: some View {
        List(workoutDay.exercises, id: \.name) { exercise in
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                Text("Recommended Reps: \(exercise.recommendedReps ?? "")")
                if let gifUrl = exercise.gifUrl {
                    Button(action: {
                        selectedGIF = GIFUrlWrapper(urlString: gifUrl)
                    }) {
                        Text("View GIF")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .navigationTitle(workoutDay.dayName)
    }
}

struct FullGIFView: View {
    let url: URL

    var body: some View {
        WebView(url: url)
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// Models
struct GIFUrlWrapper: Identifiable {
    let id = UUID()
    let urlString: String

    var url: URL? {
        return URL(string: urlString)
    }
}

struct WorkoutDay: Identifiable, Codable {
    let id = UUID()
    let dayName: String
    let exercises: [WorkoutExercise]
}

struct WorkoutExercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let target: String
    let equipment: String
    let gifUrl: String?
    let recommendedReps: String?
}
