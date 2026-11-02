import Foundation

class RecipeService {
    private let baseURL = "https://0b06-203-126-140-129.ngrok-free.app/recipes"

    /// Fetch all recipes directly from the backend
    func fetchRecipes(completion: @escaping (Result<[Recipe], Error>) -> Void) {
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

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                return
            }

            do {
                // Log raw response for debugging
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response from backend: \(rawResponse)")
                }

                let decodedResponse = try JSONDecoder().decode(RecipeList.self, from: data)
                completion(.success(decodedResponse.meals))
            } catch let DecodingError.keyNotFound(key, context) {
                print("Decoding error: Key '\(key.stringValue)' not found - \(context.debugDescription)")
                completion(.failure(NSError(domain: "DecodingError", code: 422, userInfo: [
                    NSLocalizedDescriptionKey: "Key '\(key.stringValue)' not found in response"
                ])))
            } catch {
                print("Unexpected decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }

        }.resume()
    }
}
