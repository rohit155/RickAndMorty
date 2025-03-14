//
//  NetworkManager.swift
//  RickAndMartin
//
//  Created by Rohit on 17/01/25.
//

import UIKit

class NetworkManager: NetworkService {
    
    private let baseURL: URL
    private let session: URLSession
    let cache          = NSCache<NSString, UIImage>()
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: .default)
    }
    
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
        // Ensure baseURL does not end with a trailing slash
        let baseURLString = baseURL.absoluteString
        let cleanedBaseURLString = baseURLString.hasSuffix("/") ? String(baseURLString.dropLast()) : baseURLString
        
        // Ensure the path does not start with a slash
        let path = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
        
        // Construct the URL string conditionally
        let urlString: String
        if path.isEmpty {
            urlString = cleanedBaseURLString
        } else {
            urlString = cleanedBaseURLString + "/" + path
        }
        
        // Create URLComponents from the manually constructed URL string
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Add query parameters if it's a GET request
        if endpoint.method == .GET, !endpoint.parameters.isEmpty {
            urlComponents.queryItems = endpoint.parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        // Validate the constructed URL
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Configure the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Handle POST request body
        if endpoint.method == .POST {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: endpoint.parameters)
                request.httpBody = bodyData
            } catch {
                completion(.failure(NetworkError.invalidParameters))
                return
            }
        }
        
        // Start the network task
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Validate the HTTP response status code
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NetworkError.invalidResponse(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Ensure data exists
            guard let data = data else {//
                completion(.failure(NetworkError.noData))
                return
            }
            
       

            // Return raw data to be parsed elsewhere
            do {
                // Check if T is of type Data
                if T.self == Data.self {
                    completion(.success(data as! T))  // Cast to T since we know it's Data
                } else {
                    // Try to decode the response data into the expected model
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                }
            } catch {
                completion(.failure(error))
            }

            
        }
        
        task.resume()
    }
    
    func downloadImage(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completion(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let _ = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let imageData = data,
                  let image = UIImage(data: imageData) else {
                completion(nil)
                return
            }
            
            self?.cache.setObject(image, forKey: cacheKey)
            
            completion(image)
        }.resume()
    }
    
    // Enum for enhanced error handling
    enum NetworkError: Error {
        case invalidURL
        case noData
        case invalidResponse(statusCode: Int)
        case invalidParameters
        case decodingError(Error)
    }
}
