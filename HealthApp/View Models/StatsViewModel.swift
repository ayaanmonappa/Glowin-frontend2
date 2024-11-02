//
//  StatsViewModel.swift
//  HealthApp
//
//  Created by Ayaan Monappa on 14/5/24.
//

import Foundation

class StatsViewModel: ObservableObject {
    @Published var measurements = [Measurement]()
    
    func fetchMeasurements() async throws {
        let urlString = constants.baseURL + Endpoints.measurements
        
        guard let url = URL(string: urlString) else {
            throw HttpError.badURL
        }
        
        let measurementResponse: [Measurement] = try await HttpClient.shared.fetch(url: url)
        
        DispatchQueue.main.async {
            self.measurements = measurementResponse
        }
    }
}
