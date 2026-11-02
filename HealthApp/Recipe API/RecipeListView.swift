import SwiftUI


struct RecipeListView: View {
    @State private var allRecipes: [Recipe] = []
    @State private var filteredRecipes: [Recipe] = []
    @State private var searchQuery: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Button("Get Recipes") {
                startRecipeFetching()  // Starts the fetch process
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isLoading)

            

            TextField("Search Recipes", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: searchQuery) { _ in
                    filterRecipes()
                }

            if isLoading {
                ProgressView("Fetching recipes...")
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredRecipes, id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                VStack(alignment: .leading) {
                                    if let imageURL = recipe.image, let url = URL(string: imageURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 80)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                                .frame(height: 80)
                                        }
                                    }

                                    Text(recipe.label)
                                        .font(.headline)
                                    Text("Calories: \(Int(recipe.calories)) kcal")
                                        .font(.subheadline)
                                    if let yield = recipe.yield {
                                        Text("Servings: \(Int(yield))")
                                            .font(.subheadline)
                                    }
                                    Divider()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Recipes")
        .alert(isPresented: .constant(!errorMessage.isEmpty)) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK")) {
                    errorMessage = ""
                }
            )
        }
        .onAppear {
            loadCachedRecipes()
        }
    }

    

    // Starts fetching recipes and clears cache
    func startRecipeFetching() {
        // Check if the user has set a goal
        isGoalSet { goalSet in
            guard goalSet else {
                errorMessage = "Please set a goal before fetching recipes."
                return
            }

            // Check if the user has entered measurements
            isMeasurementSet { measurementSet in
                guard measurementSet else {
                    errorMessage = "Please enter your measurements to continue."
                    return
                }

                // Start the fetching process if checks pass
                DispatchQueue.main.async {
                    isLoading = true
                    clearCachedRecipes()  // Clear any cached recipes
                }

                let recipeService = RecipeService()
                                recipeService.fetchRecipes { result in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                        switch result {
                                        case .success(let recipes):
                                            allRecipes = recipes
                                            filterRecipes()
                                            cacheRecipes(recipes)
                                        case .failure(let error):
                                            errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
                                        }
                                    }
                                }
                            }
                        }
                    }


    // Filters the recipes based on the search query
    func filterRecipes() {
        if searchQuery.isEmpty {
            filteredRecipes = allRecipes
        } else {
            filteredRecipes = allRecipes.filter { recipe in
                recipe.label.lowercased().contains(searchQuery.lowercased())
            }
        }
        print("Filtered recipes: \(filteredRecipes.count)")
    }

    // Clear the cached recipes
    func clearCachedRecipes() {
        let fileManager = FileManager.default
        let cacheURL = getCachedRecipesURL()

        // Clear in-memory cache
        allRecipes.removeAll()
        filteredRecipes.removeAll()
        print("In-memory recipes cleared.")

        // Check if the file exists before attempting to delete
        if fileManager.fileExists(atPath: cacheURL.path) {
            print("Cached recipes file exists at: \(cacheURL.path)")

            do {
                // Attempt to delete the file
                try fileManager.removeItem(at: cacheURL)
                print("Successfully cleared cached recipes.")
            } catch {
                print("Error clearing cached recipes: \(error.localizedDescription)")
            }
        } else {
            print("No cached recipes found to delete at: \(cacheURL.path)")
        }
    }

    // Load cached recipes
    func loadCachedRecipes() {
        if let cached = loadCachedRecipesFromDisk() {
            allRecipes = cached
            filterRecipes()
            print("Loaded cached recipes: \(cached.count)")
        } else {
            print("No cached recipes found.")
        }
    }
    func isGoalSet(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(constants.baseURL)/users/goal") else {
            print("Invalid URL for checking goal.")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "userToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error checking goal: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(false)
                return
            }

            // Parse the response to see if the goal is set
            do {
                let goalResponse = try JSONDecoder().decode(UpdateGoalRequest.self, from: data)
                completion(!goalResponse.goal.isEmpty)
            } catch {
                print("Failed to decode goal data: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    func isMeasurementSet(completion: @escaping (Bool) -> Void) {
        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            print("User not logged in")
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
                print("No data received from server.")
                completion(false)
                return
            }

            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                let measurements = try jsonDecoder.decode([MeasurementCreate].self, from: data)

                // Check if measurements exist in the response and are valid
                let hasValidMeasurements = measurements.last?.weight ?? 0 > 0 && measurements.last?.height ?? 0 > 0
                completion(hasValidMeasurements)
                
            } catch {
                print("Error decoding measurements data: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    
}


struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}

import Foundation

// Cache the recipes in a file using FileManager
func cacheRecipes(_ recipes: [Recipe]) {
    let fileManager = FileManager.default
    let cacheURL = getCachedRecipesURL()

    let encoder = JSONEncoder()
    do {
        let encodedData = try encoder.encode(recipes)
        try encodedData.write(to: cacheURL)
        print("Recipes successfully cached to \(cacheURL)")
    } catch {
        print("Failed to cache recipes: \(error)")
    }
}

// Load cached recipes from the file
func loadCachedRecipesFromDisk() -> [Recipe]? {
    let fileManager = FileManager.default
    let cacheURL = getCachedRecipesURL()

    do {
        let data = try Data(contentsOf: cacheURL)
        let decoder = JSONDecoder()
        let cachedRecipes = try decoder.decode([Recipe].self, from: data)
        print("Loaded cached recipes from \(cacheURL)")
        return cachedRecipes
    } catch {
        print("Failed to load cached recipes: \(error)")
        return nil
    }
}

// Get the URL for the cached recipes file
func getCachedRecipesURL() -> URL {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsURL.appendingPathComponent("cachedRecipes.json")
}
