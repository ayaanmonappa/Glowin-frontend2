import SwiftUI

struct PasswordResetRequestView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var message: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .bold()

            TextField("Enter your email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if isLoading {
                ProgressView("Sending request...")
            }

            Button("Request Password Reset") {
                requestPasswordReset()
            }
            .disabled(email.isEmpty || isLoading)
            .padding()
            .background(email.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
        }
        .padding()
    }

    func requestPasswordReset() {
        guard let url = URL(string: "https://yourapp.com/api/password-reset") else { return }
        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    message = "Failed to send request: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    message = "Password reset email sent! Check your inbox."
                } else {
                    message = "Something went wrong. Please try again."
                }
            }
        }.resume()
    }
}
