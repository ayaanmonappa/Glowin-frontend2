import Foundation

class RecipeService {
    private let baseURL = "https://8174-219-74-229-42.ngrok-free.app/recipes"

    // Initiate the recipe fetching process on the backend
    func startFetching(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "Token not found", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication token is missing."])))
            return
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 202 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Failed to start", code: 500, userInfo: nil)))
            }
        }.resume()
    }

    // Poll for the current status of the recipe fetching
    func pollForStatus(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "Token not found", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication token is missing."])))
            return
        }

        var request = URLRequest(url: URL(string: baseURL + "/status")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500, userInfo: nil)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(RecipeList.self, from: data)
                completion(.success(decodedResponse.meals))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
