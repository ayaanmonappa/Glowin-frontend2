import SwiftUI

struct PasswordResetView: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message: String?
    @State private var isLoading = false

    let token: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Set New Password")
                .font(.largeTitle)
                .bold()

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if isLoading {
                ProgressView("Updating password...")
            }

            Button("Reset Password") {
                resetPassword()
            }
            .disabled(newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword || isLoading)
            .padding()
            .background(newPassword == confirmPassword ? Color.blue : Color.gray)
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

    func resetPassword() {
        guard let url = URL(string: "https://yourapp.com/api/password-reset/\(token)") else { return }
        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["password": newPassword]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    message = "Failed to update password: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    message = "Password reset successfully. You can now log in."
                } else {
                    message = "Something went wrong. Please try again."
                }
            }
        }.resume()
    }
}
