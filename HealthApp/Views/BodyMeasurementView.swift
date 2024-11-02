import SwiftUI

struct UpdateAgeRequest: Codable {
    let age: Int
}
struct MeasurementTypeWrapper: Identifiable {
    let id = UUID()
    let type: String
}


struct UpdateActivityLevelRequest: Codable {
    let activityLevel: String
}

struct UpdateBodyTypeRequest: Codable {
    let bodyType: String
}

struct MeasurementCreate: Codable {
    let userID: UUID
    let weight: Double
    let height: Double
    let bicep: Double
    let calf: Double
    let waist: Double
    let thigh: Double
    let chest: Double
    let date: Date
}

struct BMICalculationView: View {
    @Binding var showBMICalculationView: Bool

    @State private var weight: Double? = nil
    @State private var height: Double? = nil
    @State private var bicep: Double? = nil
    @State private var calf: Double? = nil
    @State private var waist: Double? = nil
    @State private var thigh: Double? = nil
    @State private var chest: Double? = nil
    @State private var age: Int? = nil
    @State private var selectedDate = Date()
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var selectedBodyType: String? = nil
    @State private var selectedActivityLevel: String? = nil
    @State private var activeMeasurementType: MeasurementTypeWrapper?


    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Scroll down for more options")
                        .font(.headline)
                        .padding(.top)
                    createMeasurementField(title: "Weight (kg):", value: $weight, range: 30...200)
                                       createMeasurementField(title: "Height (cm):", value: $height, range: 120...220)
                    
                    createMeasurementField(title: "Bicep (cm):", value: $bicep, range: 20...60, measurementType: "Bicep")
                    createMeasurementField(title: "Calf (cm):", value: $calf, range: 25...70, measurementType: "calf")
                    createMeasurementField(title: "Waist (cm):", value: $waist, range: 50...150, measurementType: "Waist")
                    createMeasurementField(title: "Thigh (cm):", value: $thigh, range: 40...100, measurementType: "Thigh")
                    createMeasurementField(title: "Chest (cm):", value: $chest, range: 60...150, measurementType: "Chest")


                    DatePicker("Date Updated:", selection: $selectedDate, displayedComponents: .date)
                        .padding()

                    HStack {
                        Text("Age:")
                            .frame(width: 120, alignment: .leading)
                        TextField("Enter Age", value: $age, formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                            .keyboardType(.numberPad)
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Body Type:")
                            .font(.headline)
                        HStack {
                            BodyTypeButton(imageName: "ectomorph", title: "Ectomorph", selectedBodyType: $selectedBodyType)
                            BodyTypeButton(imageName: "mesomorph", title: "Mesomorph", selectedBodyType: $selectedBodyType)
                            BodyTypeButton(imageName: "endomorph", title: "Endomorph", selectedBodyType: $selectedBodyType)
                        }
                    }
                    .padding()

                    HStack {
                        Text("Activity Level:")
                            .frame(width: 120, alignment: .leading)
                        Picker("Select Activity Level", selection: Binding(
                            get: { selectedActivityLevel ?? "Moderately Active" },
                            set: { selectedActivityLevel = $0 }
                        )) {
                            Text("Sedentary").tag("Sedentary")
                            Text("Lightly Active").tag("Lightly Active")
                            Text("Moderately Active").tag("Moderately Active")
                            Text("Very Active").tag("Very Active")
                            Text("Super Active").tag("Super Active")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 150)
                    }
                    .padding()

                    Button(action: {
                        if validateMeasurements() {
                            saveMeasurement()
                            updateUserAge()
                            updateActivityLevel()
                            updateBodyType()
                        }
                    }) {
                        Text("Save")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }

                    Spacer()
                    Text("*Update once a month for best effect")
                        .padding()
                        .bold()
                }
                .padding()
            }
            .navigationTitle("Input Measurements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showBMICalculationView = false
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear(perform: fetchUserMeasurements)
            .sheet(item: $activeMeasurementType) { measurementTypeWrapper in
                MeasurementInstructionsView(measurementType: measurementTypeWrapper.type)
            }

        }
    }

  private func createMeasurementField(
            title: String,
            value: Binding<Double?>,
            range: ClosedRange<Double>,
            measurementType: String = ""
        ) -> some View {
            HStack {
                Text(title)
                    .frame(width: 120, alignment: .leading)
                TextField("Enter \(title)", value: Binding(
                    get: { value.wrappedValue ?? 0 },
                    set: { value.wrappedValue = $0 }
                ), formatter: numberFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
                
                // Show info circle only if measurementType is provided (not for weight or height)
                if !measurementType.isEmpty {
                    Button(action: {
                        self.activeMeasurementType = MeasurementTypeWrapper(type: measurementType)
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }

    struct MeasurementInstructionsView: View {
           var measurementType: String
           @Environment(\.presentationMode) var presentationMode
           
           var body: some View {
               VStack {
                   Text("How to Measure \(measurementType)")
                       .font(.title)
                       .padding()
                   
                   if measurementType.lowercased() == "calf" {
                       Text("Wrap the measuring tape around the widest part of the calf.")
                           .padding()
                           .multilineTextAlignment(.center)
                   } else {
                       Image(measurementType)
                           .resizable()
                           .scaledToFit()
                           .frame(width: 300, height: 300)
                           .onAppear {
                               print("Displaying image for: \(measurementType)")
                           }
                   }
                   
                   Text("Instructions for measuring \(measurementType).")
                       .padding()
                       .multilineTextAlignment(.center)
                   
                   Button("Close") {
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()
               }
           }
       }



    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }

    private func validateMeasurements() -> Bool {
        if weight == nil || !(30...200).contains(weight!) {
            errorMessage = "Weight must be between 30 kg and 200 kg."
            showAlert = true
            return false
        }
        if height == nil || !(120...220).contains(height!) {
            errorMessage = "Height must be between 120 cm and 220 cm."
            showAlert = true
            return false
        }
        if bicep == nil || !(20...60).contains(bicep!) {
            errorMessage = "Bicep measurement must be between 20 cm and 60 cm."
            showAlert = true
            return false
        }
        if calf == nil || !(25...70).contains(calf!) {
            errorMessage = "Calf measurement must be between 25 cm and 70 cm."
            showAlert = true
            return false
        }
        if waist == nil || !(50...150).contains(waist!) {
            errorMessage = "Waist measurement must be between 50 cm and 150 cm."
            showAlert = true
            return false
        }
        if thigh == nil || !(40...100).contains(thigh!) {
            errorMessage = "Thigh measurement must be between 40 cm and 100 cm."
            showAlert = true
            return false
        }
        if chest == nil || !(60...150).contains(chest!) {
            errorMessage = "Chest measurement must be between 60 cm and 150 cm."
            showAlert = true
            return false
        }
        return true
    }

    private func saveMeasurement() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            errorMessage = "User not logged in"
            showAlert = true
            return
        }

        guard let userID = UserDefaults.standard.string(forKey: "userID"), let uuid = UUID(uuidString: userID) else {
            errorMessage = "User ID not found"
            showAlert = true
            return
        }

        let measurement = MeasurementCreate(
            userID: uuid,
            weight: weight ?? 0,
            height: height ?? 0,
            bicep: bicep ?? 0,
            calf: calf ?? 0,
            waist: waist ?? 0,
            thigh: thigh ?? 0,
            chest: chest ?? 0,
            date: selectedDate
        )

        guard let url = URL(string: "\(constants.baseURL)\(Endpoints.measurements)") else {
            errorMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            let jsonData = try jsonEncoder.encode(measurement)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Error encoding measurement: \(error)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Error saving measurement: \(error.localizedDescription)"
                showAlert = true
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Error saving measurement: Invalid response from server."
                showAlert = true
                return
            }
            showBMICalculationView = false
        }.resume()
    }

    private func updateUserAge() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            errorMessage = "User not logged in"
            showAlert = true
            return
        }

        let updateUserRequest = UpdateAgeRequest(age: age ?? 0)

        guard let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/updateAge") else {
            errorMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(updateUserRequest)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Error encoding user update: \(error)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Error updating user: \(error.localizedDescription)"
                showAlert = true
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Error updating user: Invalid response from server."
                showAlert = true
                return
            }
        }.resume()
    }

    private func updateActivityLevel() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            errorMessage = "User not logged in"
            showAlert = true
            return
        }

        let updateRequest = UpdateActivityLevelRequest(activityLevel: selectedActivityLevel ?? "Moderately Active")

        guard let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/updateActivityLevel") else {
            errorMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(updateRequest)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Error encoding activity level update: \(error)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Error updating activity level: \(error.localizedDescription)"
                showAlert = true
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Error updating activity level: Invalid response from server."
                showAlert = true
                return
            }
        }.resume()
    }

    private func updateBodyType() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            errorMessage = "User not logged in"
            showAlert = true
            return
        }

        let updateRequest = UpdateBodyTypeRequest(bodyType: selectedBodyType ?? "Ectomorph")

        guard let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/updateBodyType") else {
            errorMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(updateRequest)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Error encoding body type update: \(error)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Error updating body type: \(error.localizedDescription)"
                showAlert = true
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Error updating body type: Invalid response from server."
                showAlert = true
                return
            }
        }.resume()
    }

    private func fetchUserMeasurements() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            errorMessage = "User not logged in"
            showAlert = true
            return
        }

        guard let url = URL(string: "\(constants.baseURL)\(Endpoints.measurements)") else {
            errorMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Error fetching measurements: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let data = data else {
                errorMessage = "No data received from server."
                showAlert = true
                return
            }

            do {
                let jsonDecoder = JSONDecoder() // Instantiate JSONDecoder
                jsonDecoder.dateDecodingStrategy = .iso8601 // Set the appropriate date decoding strategy
                let measurements = try jsonDecoder.decode([MeasurementCreate].self, from: data)
                if let latestMeasurement = measurements.last {
                    DispatchQueue.main.async {
                        weight = latestMeasurement.weight
                        height = latestMeasurement.height
                        bicep = latestMeasurement.bicep
                        calf = latestMeasurement.calf
                        waist = latestMeasurement.waist
                        thigh = latestMeasurement.thigh
                        chest = latestMeasurement.chest
                        selectedDate = latestMeasurement.date
                        
                        // Fetch user's age, body type, and activity level if stored
                        if let storedAge = UserDefaults.standard.value(forKey: "userAge") as? Int {
                            age = storedAge
                        }
                        if let storedBodyType = UserDefaults.standard.string(forKey: "bodyType") {
                            selectedBodyType = storedBodyType
                        }
                        if let storedActivityLevel = UserDefaults.standard.string(forKey: "activityLevel") {
                            selectedActivityLevel = storedActivityLevel
                        }
                    }
                }
            } catch {
                errorMessage = "Error decoding measurements: \(error)"
                showAlert = true
            }

        }.resume()
    }
}

struct BodyTypeButton: View {
    let imageName: String
    let title: String
    @Binding var selectedBodyType: String?

    var body: some View {
        Button(action: {
            selectedBodyType = title
        }) {
            VStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                Text(title)
                    .font(.headline)
                    .foregroundColor(selectedBodyType == title ? .blue : .primary)
            }
            .background(selectedBodyType == title ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(10)
            .padding(5)
        }
    }
}

struct MeasurementInstructionsView: View {
    var measurementType: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("How to Measure \(measurementType)")
                .font(.title)
                .padding()
            
            Image(measurementType)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Text("Instructions for measuring \(measurementType) will go here.")
                .padding()
                .multilineTextAlignment(.center)
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct BMICalculationView_Previews: PreviewProvider {
    @State static var showBMICalculationView: Bool = true

    static var previews: some View {
        BMICalculationView(showBMICalculationView: $showBMICalculationView)
    }
}
