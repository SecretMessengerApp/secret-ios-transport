//
//

import Foundation

extension BackendEnvironment {
    public enum FetchError: String, Error {
        case requestFailed
        case invalidResponse
    }
    
    public static func fetchEnvironment(url: URL, onCompletion: @escaping (Result<BackendEnvironment>) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                Logging.backendEnvironment.error("Error fetching configuration from \(url): \(error)")
                onCompletion(.failure(error))
            } else if let data = data {
                if let environment = BackendEnvironment(environmentType: .custom(url: url), data: data) {
                    Logging.backendEnvironment.info("Fetched custom configuration from \(url)")
                    onCompletion(.success(environment))
                } else {
                    Logging.backendEnvironment.info("Error parsing response from \(url)")
                    onCompletion(.failure(FetchError.invalidResponse))
                }
            } else {
                Logging.backendEnvironment.info("Error fetching configuration from \(url)")
                onCompletion(.failure(FetchError.requestFailed))
            }
        }.resume()
    }
}
