import SwiftUI

struct UpdateAgeView: View {
    @Binding var age: Int
    @State private var showAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            TextField("Age", value: $age, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: updateAge) {
                Text("Update Age")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }

    private func updateAge() {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            errorMessage = "User not logged in"
            showAlert = true
            return
        }

        let updateRequest = ["age": age]

        guard let url = URL(string: "\(constants.baseURL)/users/updateAge") else {
            errorMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(updateRequest)
        } catch {
            errorMessage = "Error encoding update request: \(error)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Error updating age: \(error.localizedDescription)"
                showAlert = true
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Error updating age: Invalid response from server."
                showAlert = true
                return
            }
        }.resume()
    }
}

