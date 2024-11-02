import Foundation
import Combine

class ExerciseService {
    private let baseURL = "https://exercisedb.p.rapidapi.com/exercises"
    private let headers = [
        "x-rapidapi-key": "your-api-key",
        "x-rapidapi-host": "exercisedb.p.rapidapi.com"
    ]

    func fetchExercises(bodyPart: String? = nil) -> AnyPublisher<[Exercise], Error> {
        var urlComponents = URLComponents(string: baseURL)!
        if let bodyPart = bodyPart {
            urlComponents.path = "/bodyPart/\(bodyPart)"
        }

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [Exercise].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
