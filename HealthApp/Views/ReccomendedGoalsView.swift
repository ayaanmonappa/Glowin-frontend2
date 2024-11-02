import SwiftUI

struct RecommendedGoalsView: View {
    @Binding var goals: [GeneratedGoal.GoalPublic]
    @State private var measurements: [Measurement.MeasurementPublic] = []
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Current Measurements")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    if let latestMeasurement = measurements.last {
                        VStack(alignment: .leading, spacing: 10) {
                            StatRow(title: "Weight", currentValue: latestMeasurement.weight)
                            StatRow(title: "Height", currentValue: latestMeasurement.height)
                            StatRow(title: "Bicep", currentValue: latestMeasurement.bicep)
                            StatRow(title: "Calf", currentValue: latestMeasurement.calf)
                            StatRow(title: "Waist", currentValue: latestMeasurement.waist)
                            StatRow(title: "Thigh", currentValue: latestMeasurement.thigh)
                            StatRow(title: "Chest", currentValue: latestMeasurement.chest)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    } else {
                        Text("No measurements available")
                            .padding()
                    }

                    Text("Recommended Goals")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    if goals.isEmpty {
                        Text("No goals available")
                            .padding()
                    } else {
                        ForEach(goals) { goal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Current \(goal.measurementType):")
                                        .font(.headline)
                                    Text("\(currentMeasurementValue(for: goal.measurementType))")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Goal \(goal.measurementType):")
                                        .font(.headline)
                                    Text("\(goal.goalValue, specifier: "%.2f")")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Recommended Goals")
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.blue)
            })
            .onAppear {
                fetchMeasurements()
                fetchGoals()
            }
        }
    }

    private func fetchMeasurements() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            print("User token not found.")
            return
        }

        guard let url = URL(string: "\(constants.baseURL)/measurements") else {
            print("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching measurements: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let measurements = try decoder.decode([Measurement.MeasurementPublic].self, from: data)
                DispatchQueue.main.async {
                    self.measurements = measurements
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error decoding measurements: \(error)")
                }
            }
        }.resume()
    }

    private func fetchGoals() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            print("User token not found.")
            return
        }

        guard let url = URL(string: "\(constants.baseURL)/goals") else {
            print("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching goals: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let goals = try decoder.decode([GeneratedGoal.GoalPublic].self, from: data)
                DispatchQueue.main.async {
                    self.goals = goals
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error decoding goals: \(error)")
                }
            }
        }.resume()
    }

    private func currentMeasurementValue(for type: String) -> String {
        guard let latestMeasurement = measurements.last else { return "" }
        
        switch type.lowercased() {
        case "weight":
            return "\(latestMeasurement.weight) kg"
        case "height":
            return "\(latestMeasurement.height) cm"
        case "bicep":
            return "\(latestMeasurement.bicep) cm"
        case "calf":
            return "\(latestMeasurement.calf) cm"
        case "waist":
            return "\(latestMeasurement.waist) cm"
        case "thigh":
            return "\(latestMeasurement.thigh) cm"
        case "chest":
            return "\(latestMeasurement.chest) cm"
        case "bmi":
            return String(format: "%.2f", calculateBMI(weight: latestMeasurement.weight, height: latestMeasurement.height))
        case "hip-to-waist ratio":
            return String(format: "%.2f", calculateHipToWaistRatio(waist: latestMeasurement.waist, hip: latestMeasurement.thigh))
        default:
            return ""
        }
    }

    private func calculateBMI(weight: Double, height: Double) -> Double {
        return weight / ((height / 100) * (height / 100))
    }

    private func calculateHipToWaistRatio(waist: Double, hip: Double) -> Double {
        return waist / hip
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

struct StatRow: View {
    let title: String
    let currentValue: Double

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 120, alignment: .leading)
            Text(String(format: "%.2f", currentValue))
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct RecommendedGoalsView_Previews: PreviewProvider {
    @State static var sampleGoals = [
        GeneratedGoal.GoalPublic(
            id: UUID(),
            measurementType: "Weight",
            goalValue: 70,
            targetDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3 * 30 * 24 * 60 * 60)),  // Provide String
            dateGenerated: ISO8601DateFormatter().string(from: Date())  // Provide String
        ),
        GeneratedGoal.GoalPublic(
            id: UUID(),
            measurementType: "Height",
            goalValue: 170,
            targetDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(6 * 30 * 24 * 60 * 60)),  // Provide String
            dateGenerated: ISO8601DateFormatter().string(from: Date())  // Provide String
        )
    ]

    static var previews: some View {
        RecommendedGoalsView(goals: $sampleGoals)
    }
}
