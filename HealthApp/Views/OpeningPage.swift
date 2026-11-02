import SwiftUI
import SwiftData

struct OpeningPage: View {
    @Environment(\.modelContext) private var modelContext
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var gender = "Male"
    @State private var age = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var isLoggedIn = false
    @State private var isShowingLogin = false
    @State private var isSubmit = false
    @State private var emailForConfirmation = ""
    @State private var isUsernameTaken = false
       @State private var isEmailTaken = false
       

    var body: some View {
        NavigationStack {
            ZStack{
            VStack {
                Text("Take control of your life")
                    .font(.title2)
                    .padding(.top, -15)
                    .padding()
                
                HStack(spacing: 13) {
                    VStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .fill(Color(white: 0.15))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image("health")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                
                            )
                        
                    }
                    
                }
                .padding(.top, -20)
                .padding()
                
                Text("Glowin")
                    .font(.title3)
                    .bold()
                    .padding(.top, -20)
                    .padding()
                
                
                Text("Create an account:")
                    .font(.title)
                    .padding(.top, -10)
                
                TextField("Email", text: $email, onEditingChanged: { _ in
                    checkEmailAvailability()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 0)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                if isEmailTaken {
                    Text("Email is already registered.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 0)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 0)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                VStack {
                    TextField("Username", text: $username, onEditingChanged: { _ in
                        checkUsernameAvailability()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 0)
                    .autocapitalization(.none)
                    
                    if isUsernameTaken {
                        Text("Username is already taken.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    TextField("Age", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 0)
                        .keyboardType(.numberPad)
                    
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 0)
                    
                    Button(action: {
                        showAlert.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .padding()
                            .foregroundColor(.blue)
                    }
                }
                
                Button("Submit") {
                    if !isValidEmail(email) {
                        errorMessage = "Invalid email format."
                        showAlert.toggle()
                        return
                    }
                    if isEmailTaken {
                        errorMessage = "Email is already registered."
                        showAlert.toggle()
                        return
                    }
                    if !isValidPassword(password) {
                        errorMessage = "Password must contain at least 8 characters, 1 capital letter, and 1 symbol."
                        showAlert.toggle()
                        return
                    }
                    if password != confirmPassword {
                        errorMessage = "Passwords do not match."
                        showAlert.toggle()
                        return
                    }
                    if isUsernameTaken {
                        errorMessage = "Username is already taken."
                        showAlert.toggle()
                        return
                    }
                    if !isValidAge(age) {
                        errorMessage = "Age must be between 10 and 80."
                        showAlert.toggle()
                        return
                    }
                    
                    registerUser()
                }
                .padding()
                .padding(.top,-20)
                .foregroundColor(.blue)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(""),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK")) {
                            // Only navigate if registration was successful
                            if errorMessage.contains("Registration successful") {
                                isSubmit = true
                            }
                        }
                    )
                }
                
                
                Divider()
                    .padding(.vertical)
                
                Button("Login") {
                    isShowingLogin = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 40)
            }
            .padding()
            .sheet(isPresented: $isShowingLogin) {
                LoginPage()
            }
            .navigationDestination(isPresented: $isSubmit) {
                LoginPage()
            }
        }
        }
    }
    func isValidEmail(_ email: String) -> Bool {
           let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
           return emailTest.evaluate(with: email)
       }
    func isValidAge(_ age: String) -> Bool {
            if let ageInt = Int(age) {
                return ageInt >= 10 && ageInt <= 80
            }
            return false
        }
    
    func checkUsernameAvailability() {
           guard !username.isEmpty else { return }
           
           guard let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/check-username?username=\(username)") else { return }

           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error checking username: \(error.localizedDescription)")
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse else { return }
               DispatchQueue.main.async {
                   isUsernameTaken = httpResponse.statusCode == 409  // Conflict if username exists
               }
           }.resume()
       }
func checkEmailAvailability() {
        guard !email.isEmpty else { return }
        
        // Ensure the email is URL-encoded
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(constants.baseURL)\(Endpoints.users)/check-email?email=\(encodedEmail)") else {
            print("Invalid URL for checking email availability")
            return
        }

        print("Checking email with URL: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error checking email: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data, let body = String(data: data, encoding: .utf8) {
                print("Response Body: \(body)")
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid response from server")
                return
            }
            
            DispatchQueue.main.async {
                isEmailTaken = httpResponse.statusCode == 409  // Conflict if email exists
            }
        }.resume()
    }


    
    func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex).evaluate(with: password) else { return false }
        let symbolRegex = ".*[^A-Za-z0-9]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", symbolRegex).evaluate(with: password) else { return false }
        return true
    }
    

 func registerUser() {
     guard let ageInt = Int(age) else {
         errorMessage = "Invalid age"
         showAlert = true
         return
     }
     
     let user = User(username: username, email: email, password: password, gender: gender, age: ageInt)
     guard let url = URL(string: constants.baseURL + Endpoints.users + "/create") else {
         errorMessage = "Invalid URL."
         showAlert = true
         return
     }

     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     do {
         request.httpBody = try JSONEncoder().encode(user)
     } catch {
         errorMessage = "Failed to encode user data."
         showAlert = true
         return
     }

     URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
             DispatchQueue.main.async {
                 errorMessage = "Error registering user: \(error.localizedDescription)"
                 showAlert = true
             }
             return
         }

         if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
             DispatchQueue.main.async {
                 errorMessage = "Error: Received HTTP \(httpResponse.statusCode)"
                 showAlert = true
             }
             return
         }

         // Navigate to the login page on successful registration
         DispatchQueue.main.async {
             errorMessage = "Registration successful"
             isSubmit = true
             print("Navigating to login page: \(isSubmit)")
         }
     }.resume()
 }


}

struct OpeningPage_Previews: PreviewProvider {
    static var previews: some View {
        OpeningPage()
    }
}
