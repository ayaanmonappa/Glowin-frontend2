import SwiftUI

struct LoginPage: View {
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isLoggedIn = false
    @State private var errorMessage = ""
    @State private var showAlert = false
 

    var body: some View {
        NavigationStack {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Toggle("Remember Me", isOn: $rememberMe)
                    .padding()
                    .foregroundColor(.blue)
                
                Button("Login") {
                    loginUser()
                }
                .padding()
               
            }
            .padding()
            .navigationTitle("Login")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadLoginCredentials()
            }
            .fullScreenCover(isPresented: $isLoggedIn) {
                HomePage()
            }
            
        }
    }

    func loginUser() {
            guard let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/login") else {
                errorMessage = "Invalid URL."
                showAlert = true
                return
            }

            clearToken()

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let loginCredentials = ["username": username, "password": password]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: loginCredentials, options: [])
            } catch {
                errorMessage = "Failed to encode credentials."
                showAlert = true
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = "Error logging in: \(error.localizedDescription)"
                        showAlert = true
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        errorMessage = "No response from server."
                        showAlert = true
                    }
                    return
                }
                
                if httpResponse.statusCode == 403 {
                    DispatchQueue.main.async {
                        errorMessage = "Please verify your email before logging in."
                        showAlert = true
                    }
                    return
                }
                
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        errorMessage = "Incorrect username or password."
                        showAlert = true
                    }
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        errorMessage = "Incorrect username or password."
                        showAlert = true
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        errorMessage = "No data received from server."
                        showAlert = true
                    }
                    return
                }

                do {
                    let token = try JSONDecoder().decode(UserToken.self, from: data)
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(token.value, forKey: "userToken")
                        UserDefaults.standard.set(token.user.id.uuidString, forKey: "userID")

                        if rememberMe {
                            saveLoginCredentials()
                        } else {
                            clearSavedCredentials()
                        }

                        isLoggedIn = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to decode server response."
                        showAlert = true
                    }
                }
            }.resume()
        }



    func saveLoginCredentials() {
        UserDefaults.standard.set(username, forKey: "SavedUsername")
        UserDefaults.standard.set(password, forKey: "SavedPassword")
    }
    
    func loadLoginCredentials() {
        if let savedUsername = UserDefaults.standard.string(forKey: "SavedUsername"),
           let savedPassword = UserDefaults.standard.string(forKey: "SavedPassword") {
            username = savedUsername
            password = savedPassword
            rememberMe = true
        }
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "userID")
    }

    func clearSavedCredentials() {
        UserDefaults.standard.removeObject(forKey: "SavedUsername")
        UserDefaults.standard.removeObject(forKey: "SavedPassword")
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
enum AlertType: Identifiable {
    case error(String) // Error with a message
    case success(String) // Success with a message
    
    var id: String {
        switch self {
        case .error(let message):
            return "error-\(message)"
        case .success(let message):
            return "success-\(message)"
        }
    }
}



