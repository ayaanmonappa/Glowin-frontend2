
    import SwiftUI
    import Charts
    
    struct StatisticsView: View {
        @State private var selectedMeasurement: String? = nil
        @State private var measurements: [Measurement.MeasurementPublic] = []
        @State private var goals: [GeneratedGoal.GoalPublic] = []
        
        var body: some View {
            VStack {
                if let selectedMeasurement = selectedMeasurement {
                    ProgressChart(
                        measurements: measurements,
                        goals: goals,
                        selectedMeasurement: selectedMeasurement
                    )
                    .frame(height: 300)
                    .padding()
                } else {
                    Text("Select a measurement to view progress.")
                        .font(.headline)
                        .padding()
                }
                
                HStack {
                    FilterButton(title: "Weight", selectedMeasurement: $selectedMeasurement)
                    FilterButton(title: "Bicep", selectedMeasurement: $selectedMeasurement)
                    FilterButton(title: "Calf", selectedMeasurement: $selectedMeasurement)
                    FilterButton(title: "Waist", selectedMeasurement: $selectedMeasurement)
                    FilterButton(title: "Thigh", selectedMeasurement: $selectedMeasurement)
                    FilterButton(title: "Chest", selectedMeasurement: $selectedMeasurement)
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                fetchData()
            }
            .navigationTitle("Progress Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
        
        private func fetchData() {
            let userToken = UserDefaults.standard.string(forKey: "userToken") ?? ""
            fetchMeasurements(userToken: userToken)
            fetchGoals(userToken: userToken)
        }
        
        private func fetchMeasurements(userToken: String) {
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
                        }
                    } catch {
                        print("Error decoding measurements: \(error)")
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
                            self.goals = goals
                            print("Fetched goals: \(goals)")
                        }
                    } catch {
                        print("Error decoding goals: \(error)")
                    }
                }
            }.resume()
        }

    }

struct FilterButton: View {
    let title: String
    @Binding var selectedMeasurement: String?

    var body: some View {
        Button(action: {
            selectedMeasurement = title
        }) {
            Text(title)
                .padding(5)
                .background(selectedMeasurement == title ? Color.blue.opacity(0.6) : Color.blue.opacity(0.2))
                .cornerRadius(5)
        }
    }
}
